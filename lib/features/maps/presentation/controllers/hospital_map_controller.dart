import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../data/models/hospital_model.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/distance_util.dart';
import "package:smart_clinic_booking/shared/di/injection.dart";
import '../../domain/repositories/maps_repository.dart';
import 'dart:async';

class HospitalMapState {
  final bool isLoading;
  final Position? userLocation;
  final List<HospitalEntity> hospitals;        // All hospitals
  final List<HospitalEntity> filteredHospitals; // After search/filter
  final HospitalEntity? selectedHospital;
  final String? error;

  const HospitalMapState({
    this.isLoading = false,
    this.userLocation,
    this.hospitals = const [],
    this.filteredHospitals = const [],
    this.selectedHospital,
    this.error,
  });

  HospitalMapState copyWith({
    bool? isLoading,
    Position? userLocation,
    List<HospitalEntity>? hospitals,
    List<HospitalEntity>? filteredHospitals,
    HospitalEntity? selectedHospital,
    String? error,
    bool clearSelected = false,
  }) {
    return HospitalMapState(
      isLoading: isLoading ?? this.isLoading,
      userLocation: userLocation ?? this.userLocation,
      hospitals: hospitals ?? this.hospitals,
      filteredHospitals: filteredHospitals ?? this.filteredHospitals,
      selectedHospital: clearSelected ? null : (selectedHospital ?? this.selectedHospital),
      error: error,
    );
  }
}

class HospitalMapController extends StateNotifier<HospitalMapState> {
  final MapsRepository repository;
  final LocationService locationService;
  Timer? _debounce;

  HospitalMapController({required this.repository, required this.locationService})
      : super(const HospitalMapState()) {
    _initData();
  }

  Future<void> _initData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Get User Location (graceful fallback if denied)
      Position? position;
      try {
        position = await locationService.getCurrentLocation();
      } catch (e) {
        // Fallback to center of HCMC if GPS disabled/denied
        debugPrint("Location Error: ${e.toString()}");
      }

      // 2. Fetch Hospitals
      final list = await repository.getHospitals();

      // 3. Sort by distance if we have location
      if (position != null) {
        list.sort((a, b) {
          final distA = DistanceUtil.calculateDistance(position!.latitude, position.longitude, a.lat, a.lng);
          final distB = DistanceUtil.calculateDistance(position.latitude, position.longitude, b.lat, b.lng);
          return distA.compareTo(distB);
        });
      }

      state = state.copyWith(
        isLoading: false,
        userLocation: position,
        hospitals: list,
        filteredHospitals: list,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectHospital(HospitalEntity? hospital) {
    state = state.copyWith(selectedHospital: hospital, clearSelected: hospital == null);
  }

  Future<void> findNearby() async {
    state = state.copyWith(isLoading: true);
    try {
      final position = await locationService.getCurrentLocation();
      final list = await repository.getHospitals();

      // Filter within 5km and Sort
      final nearby = list.where((h) {
        final dist = DistanceUtil.calculateDistance(position.latitude, position.longitude, h.lat, h.lng);
        return dist <= 5.0; // 5km limit as per requirement
      }).toList();

      nearby.sort((a, b) {
        final distA = DistanceUtil.calculateDistance(position.latitude, position.longitude, a.lat, a.lng);
        final distB = DistanceUtil.calculateDistance(position.latitude, position.longitude, b.lat, b.lng);
        return distA.compareTo(distB);
      });

      state = state.copyWith(
        isLoading: false,
        userLocation: position,
        filteredHospitals: nearby.isEmpty ? list : nearby,
        selectedHospital: nearby.isNotEmpty ? nearby.first : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void searchHospitals(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        state = state.copyWith(filteredHospitals: state.hospitals);
        return;
      }
      final lowerQuery = query.toLowerCase();
      final filtered = state.hospitals.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
               p.specialties.any((s) => s.toLowerCase().contains(lowerQuery));
      }).toList();
      state = state.copyWith(filteredHospitals: filtered);
    });
  }

  void filterByDistanceRadius(double kmRadius) {
    if (state.userLocation == null) return;
    
    final filtered = state.hospitals.where((p) {
      final dist = DistanceUtil.calculateDistance(
        state.userLocation!.latitude,
        state.userLocation!.longitude,
        p.lat,
        p.lng,
      );
      return dist <= kmRadius;
    }).toList();

    state = state.copyWith(filteredHospitals: filtered);
  }
}

// Provider
final hospitalMapProvider = StateNotifierProvider<HospitalMapController, HospitalMapState>((ref) {
  return HospitalMapController(
    repository: getIt<MapsRepository>(),
    locationService: LocationService(),
  );
});

// Lightweight provider for the home screen featured hospitals section.
// Queries Firestore directly to avoid the SQLite caching layer swallowing errors.
// Returns hospitals marked as featured; falls back to top-rated if none marked.
final featuredHospitalsProvider = FutureProvider<List<HospitalEntity>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .get(const GetOptions(source: Source.serverAndCache));

    debugPrint('[FeaturedHospitals] Fetched ${snapshot.docs.length} hospitals from Firestore');

    if (snapshot.docs.isEmpty) {
      debugPrint('[FeaturedHospitals] Collection is empty – seed may not have run yet');
      return [];
    }

    final all = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return HospitalModel.fromJson(data) as HospitalEntity;
    }).toList();

    final featured = all.where((h) => h.featured).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    if (featured.isNotEmpty) {
      debugPrint('[FeaturedHospitals] Returning ${featured.length} featured hospitals');
      return featured.take(6).toList();
    }

    // Fallback: top 6 by rating
    final sorted = List<HospitalEntity>.from(all)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    debugPrint('[FeaturedHospitals] No featured flag – returning top ${sorted.take(6).length} by rating');
    return sorted.take(6).toList();
  } catch (e) {
    debugPrint('[FeaturedHospitals] Error: $e');
    rethrow;
  }
});

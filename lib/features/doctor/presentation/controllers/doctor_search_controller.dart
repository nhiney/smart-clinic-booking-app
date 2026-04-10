import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/doctor_catalog_query.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_catalog_doctors_usecase.dart';

enum DoctorSearchViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class DoctorSearchController extends ChangeNotifier {
  DoctorSearchController({
    required GetCatalogDoctorsUseCase getCatalogDoctors,
    Connectivity? connectivity,
  })  : _getCatalogDoctors = getCatalogDoctors,
        _connectivity = connectivity ?? Connectivity();

  final GetCatalogDoctorsUseCase _getCatalogDoctors;
  final Connectivity _connectivity;

  DoctorSearchViewState viewState = DoctorSearchViewState.initial;
  List<DoctorEntity> doctors = [];
  String searchText = '';
  String specialtyFilter = '';
  double? minRating;
  String locationFilter = '';
  DoctorCatalogSort sort = DoctorCatalogSort.ratingDesc;
  String? errorMessage;
  List<String> specialtyOptions = [];
  Timer? _debounce;

  bool get hasActiveFilters =>
      searchText.trim().isNotEmpty ||
      (specialtyFilter.trim().isNotEmpty) ||
      minRating != null ||
      locationFilter.trim().isNotEmpty;

  void onSearchChanged(String value) {
    searchText = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 360), () {
      load();
    });
    notifyListeners();
  }

  void setSpecialty(String? value) {
    specialtyFilter = value ?? '';
    load();
  }

  void setMinRating(double? value) {
    minRating = value;
    load();
  }

  void setLocationFilter(String value) {
    locationFilter = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 360), () {
      load();
    });
    notifyListeners();
  }

  void setSort(DoctorCatalogSort value) {
    sort = value;
    load();
  }

  Future<void> load() async {
    final connected = await _isOnline();
    if (!connected) {
      viewState = DoctorSearchViewState.error;
      errorMessage =
          'Không có kết nối mạng. Vui lòng kiểm tra Wi‑Fi hoặc dữ liệu di động.';
      notifyListeners();
      return;
    }

    double? uLat;
    double? uLng;
    if (sort == DoctorCatalogSort.nearest) {
      final pos = await _tryUserPosition();
      uLat = pos?.$1;
      uLng = pos?.$2;
      if (uLat == null || uLng == null) {
        if (kDebugMode) {
          debugPrint('[DoctorSearch] Nearest sort: missing position, falling back to rating.');
        }
      }
    }

    viewState = DoctorSearchViewState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final query = DoctorCatalogQuery(
        searchText: searchText.trim().isEmpty ? null : searchText.trim(),
        specialty: specialtyFilter.trim().isEmpty ? null : specialtyFilter.trim(),
        minRating: minRating,
        locationSubstring:
            locationFilter.trim().isEmpty ? null : locationFilter.trim(),
        sort: sort,
        userLatitude: uLat,
        userLongitude: uLng,
      );

      final result = await _getCatalogDoctors(query);
      doctors = result;
      _mergeSpecialtyOptions(result);
      if (doctors.isEmpty) {
        viewState = DoctorSearchViewState.empty;
      } else {
        viewState = DoctorSearchViewState.loaded;
      }
    } catch (e, stackTrace) {
      debugPrint('[DoctorSearch] $e\n$stackTrace');
      viewState = DoctorSearchViewState.error;
      errorMessage = _mapError(e);
    }

    notifyListeners();
  }

  Future<void> retry() => load();

  void clearFilters() {
    _debounce?.cancel();
    searchText = '';
    specialtyFilter = '';
    minRating = null;
    locationFilter = '';
    sort = DoctorCatalogSort.ratingDesc;
    notifyListeners();
    load();
  }

  Future<bool> _isOnline() async {
    try {
      final r = await _connectivity.checkConnectivity();
      if (r.isEmpty) return true;
      return !r.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<(double, double)?> _tryUserPosition() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      return (p.latitude, p.longitude);
    } catch (_) {
      return null;
    }
  }

  void _mergeSpecialtyOptions(List<DoctorEntity> list) {
    final set = <String>{...specialtyOptions};
    for (final d in list) {
      final s = d.specialty.trim();
      if (s.isNotEmpty) set.add(s);
    }
    specialtyOptions = set.toList()..sort();
    if (specialtyFilter.isNotEmpty &&
        !specialtyOptions.contains(specialtyFilter)) {
      specialtyFilter = '';
    }
  }

  String _mapError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Không có quyền đọc danh sách bác sĩ (Firestore).';
        case 'unavailable':
          return 'Dịch vụ tạm thời không khả dụng. Thử lại sau.';
        default:
          return e.message?.isNotEmpty == true
              ? e.message!
              : 'Lỗi Firestore (${e.code}).';
      }
    }
    return 'Không thể tải danh sách bác sĩ.';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

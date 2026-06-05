import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/doctor_catalog_query.dart';
import '../../domain/entities/doctor_entity.dart';
import '../models/doctor_model.dart';

@lazySingleton
class DoctorRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int _catalogFetchCap = 200;

  Future<List<DoctorModel>> getDoctors() async {
    final snapshot = await _firestore.collection('doctors').get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    if (!doc.exists) return null;
    return DoctorModel.fromJson(doc.data()!, doc.id);
  }

  /// Resolves document id or `doctorId` field.
  Future<DoctorModel?> getDoctorCatalogById(String doctorId) async {
    try {
      final direct = await _firestore.collection('doctors').doc(doctorId).get();
      if (direct.exists) {
        return DoctorModel.fromJson(direct.data()!, direct.id);
      }
      final q = await _firestore
          .collection('doctors')
          .where('doctorId', isEqualTo: doctorId)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      final d = q.docs.first;
      return DoctorModel.fromJson(d.data(), d.id);
    } on FirebaseException catch (e) {
      debugPrint('[DoctorCatalog] getDoctorCatalogById: ${e.code} ${e.message}');
      rethrow;
    }
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    final snapshot = await _firestore.collection('doctors').get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .where((doctor) =>
            doctor.name.toLowerCase().contains(lowerQuery) ||
            doctor.specialty.toLowerCase().contains(lowerQuery) ||
            doctor.hospital.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filtered catalog search with Firestore query + in-memory refinement.
  Future<List<DoctorModel>> searchDoctorsCatalog(DoctorCatalogQuery q) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('doctors');
      final spec = q.specialty?.trim();
      if (spec != null && spec.isNotEmpty) {
        query = query.where('specialty', isEqualTo: spec);
      }
      query = query.orderBy('rating', descending: true);
      final snap = await query.limit(_catalogFetchCap).get();
      var list =
          snap.docs.map((d) => DoctorModel.fromJson(d.data(), d.id)).toList();

      if (list.length >= _catalogFetchCap) {
        // Avoid silent truncation confusion: if capped, note in debug.
        debugPrint(
            '[DoctorCatalog] Hit fetch cap ($_catalogFetchCap); refine filters locally.');
      }

      list = _applyLocalFilters(list, q);
      list = _applySort(list, q);
      return list;
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        debugPrint(
            '[DoctorCatalog] Composite index may be missing; falling back to unordered fetch.');
        final snap =
            await _firestore.collection('doctors').limit(_catalogFetchCap).get();
        var list = snap.docs
            .map((d) => DoctorModel.fromJson(d.data(), d.id))
            .toList();
        list = _applyLocalFilters(list, q);
        list = _applySort(list, q);
        return list;
      }
      rethrow;
    }
  }

  List<DoctorModel> _applyLocalFilters(
    List<DoctorModel> list,
    DoctorCatalogQuery q,
  ) {
    var out = list;

    final text = q.searchText?.trim().toLowerCase();
    if (text != null && text.isNotEmpty) {
      out = out.where((d) {
        return d.name.toLowerCase().contains(text) ||
            d.specialty.toLowerCase().contains(text) ||
            d.displayClinic.toLowerCase().contains(text) ||
            d.location.toLowerCase().contains(text);
      }).toList();
    }

    final minR = q.minRating;
    if (minR != null) {
      out = out.where((d) => d.rating >= minR).toList();
    }

    final loc = q.locationSubstring?.trim().toLowerCase();
    if (loc != null && loc.isNotEmpty) {
      out = out
          .where(
            (d) =>
                d.location.toLowerCase().contains(loc) ||
                d.displayClinic.toLowerCase().contains(loc),
          )
          .toList();
    }

    return out;
  }

  List<DoctorModel> _applySort(List<DoctorModel> list, DoctorCatalogQuery q) {
    final sorted = List<DoctorModel>.from(list);

    switch (q.sort) {
      case DoctorCatalogSort.ratingDesc:
        sorted.sort((a, b) {
          final c = b.rating.compareTo(a.rating);
          if (c != 0) return c;
          return b.totalReviews.compareTo(a.totalReviews);
        });
        break;
      case DoctorCatalogSort.popular:
        sorted.sort((a, b) {
          final c = b.totalReviews.compareTo(a.totalReviews);
          if (c != 0) return c;
          return b.rating.compareTo(a.rating);
        });
        break;
      case DoctorCatalogSort.nearest:
        final uLat = q.userLatitude;
        final uLng = q.userLongitude;
        if (uLat == null || uLng == null) {
          sorted.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        }
        sorted.sort((a, b) {
          final da = DoctorCatalogQuery.haversineKm(
                uLat,
                uLng,
                a.latitude,
                a.longitude,
              ) ??
              double.maxFinite;
          final db = DoctorCatalogQuery.haversineKm(
                uLat,
                uLng,
                b.latitude,
                b.longitude,
              ) ??
              double.maxFinite;
          return da.compareTo(db);
        });
        break;
      case DoctorCatalogSort.experienceDesc:
        sorted.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case DoctorCatalogSort.experienceAsc:
        sorted.sort((a, b) => a.experience.compareTo(b.experience));
        break;
    }
    return sorted;
  }

  /// Applies distanceKm on models when user coords exist (for UI).
  List<DoctorEntity> withDistances(
    List<DoctorModel> models,
    double? userLat,
    double? userLng,
  ) {
    if (userLat == null || userLng == null) return models;

    return models.map((m) {
      final km = DoctorCatalogQuery.haversineKm(
        userLat,
        userLng,
        m.latitude,
        m.longitude,
      );
      return DoctorModel(
        id: m.id,
        name: m.name,
        specialty: m.specialty,
        hospital: m.hospital,
        imageUrl: m.imageUrl,
        rating: m.rating,
        totalReviews: m.totalReviews,
        experience: m.experience,
        about: m.about,
        resumePdfUrl: m.resumePdfUrl,
        departmentId: m.departmentId,
        latitude: m.latitude,
        longitude: m.longitude,
        phone: m.phone,
        availableDays: m.availableDays,
        availableTimeSlots: m.availableTimeSlots,
        clinicName: m.clinicName,
        location: m.location,
        schedule: m.schedule,
        distanceKm: km,
      );
    }).toList();
  }

  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    final snapshot = await _firestore
        .collection('doctors')
        .where('specialty', isEqualTo: specialty)
        .get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<List<DoctorModel>> getUnassignedDoctors() async {
    final snapshot = await _firestore
        .collection('doctors')
        .where('departmentId', isEqualTo: '')
        .get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> assignDoctorToDepartment({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  }) async {
    await _firestore.collection('doctors').doc(doctorId).update({
      'hospital': hospitalId,
      'departmentId': departmentId,
    });
  }

  Future<void> updateDoctorProfile(DoctorModel doctor) async {
    await _firestore
        .collection('doctors')
        .doc(doctor.id)
        .update(doctor.toJson());
  }
}

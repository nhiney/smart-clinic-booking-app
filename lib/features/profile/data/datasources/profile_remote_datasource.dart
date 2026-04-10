import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/patient_profile.dart';
import '../models/patient_profile_model.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> _fetchWithRetry(DocumentReference docRef, {int maxAttempts = 3}) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        return await docRef.get(const GetOptions(source: Source.serverAndCache));
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts || !e.toString().contains('unavailable')) {
          rethrow;
        }
        final delaySeconds = pow(2, attempt).toInt();
        debugPrint('[FIRESTORE] Lỗi unavailable. Thử lại lần $attempt sau $delaySeconds giây...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    throw Exception("Không thể kết nối máy chủ sau nhiều lần thử.");
  }

  Future<UserEntity?> getProfile(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await _fetchWithRetry(docRef);
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint('Error getting profile with retry: $e');
      return null;
    }
  }

  Future<void> updateProfile(UserEntity user) async {
    await _firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'phone': user.phone,
      'avatarUrl': user.avatarUrl,
    });
  }

  Future<PatientProfile?> getPatientProfile(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final doc = await _fetchWithRetry(docRef);
      if (!doc.exists || doc.data() == null) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['profile'] == null) return null;
      
      return PatientProfileModel.fromMap(data['profile'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting patient profile: $e');
      rethrow;
    }
  }

  Future<void> updatePatientProfile(PatientProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final profileModel = PatientProfileModel.fromEntity(profile);
    final profileData = profileModel.toMap();

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'role': 'patient',
      'profile': profileData,
    }, SetOptions(merge: true));
  }
}

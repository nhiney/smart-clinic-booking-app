import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

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
}

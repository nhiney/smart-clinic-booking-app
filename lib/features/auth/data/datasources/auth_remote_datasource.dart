import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// LOGIN
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final fakeEmail = '${phone.replaceAll(RegExp(r'\D'), '')}@smartclinic.com';
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      final user = result.user!;

      // Try to get user profile from Firestore
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data()!, user.uid);
        }
      } catch (e) {
        debugPrint('Firestore get profile error: $e');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  /// REGISTER
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    String role = 'patient',
  }) async {
    try {
      final fakeEmail = '${phone.replaceAll(RegExp(r'\D'), '')}@smartclinic.com';
      // Step 1: Create Firebase Auth account
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      // Step 2: Update display name
      try {
        await result.user!.updateDisplayName(name);
      } catch (e) {
        debugPrint('Update display name error: $e');
      }

      final userModel = UserModel(
        id: result.user!.uid,
        email: '',
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      // Step 3: Save user profile to Firestore (non-blocking for auth success)
      try {
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toJson());
      } catch (e) {
        debugPrint('Firestore save profile error: $e');
        // Auth account was created successfully, profile save failed
        // We still return success - profile can be created later
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// CURRENT USER
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// GET USER PROFILE
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('Get user profile error: $e');
    }
    return null;
  }

  /// UPDATE USER PROFILE
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      debugPrint('Update user profile error: $e');
      throw Exception('Cập nhật hồ sơ thất bại');
    }
  }

  /// ERROR HANDLER
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'invalid-credential':
        return 'Số điện thoại hoặc mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Số điện thoại đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'invalid-email':
        return 'Số điện thoại không hợp lệ';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      case 'operation-not-allowed':
        return 'Chức năng đăng ký chưa được kích hoạt';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Lỗi xác thực ($code)';
    }
  }
}

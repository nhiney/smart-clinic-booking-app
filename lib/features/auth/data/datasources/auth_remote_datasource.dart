import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

@lazySingleton
class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Normalizes phone number to digits-only format, replacing leading 0 with 84 for VN
  String _normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0') && clean.length == 10) {
      clean = '84${clean.substring(1)}';
    }
    return clean;
  }

  /// LOGIN
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      final fakeEmail = '$normalizedPhone@smartclinic.com';
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
      final normalizedPhone = _normalizePhone(phone);
      final fakeEmail = '$normalizedPhone@smartclinic.com';
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

  /// GET USER PROFILE (With Retry)
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
        debugPrint('[FIRESTORE] Auth getProfile bị lỗi unavailable. Thử lại lần $attempt sau $delaySeconds giây...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    throw Exception("Không thể kết nối máy chủ sau nhiều lần thử.");
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await _fetchWithRetry(docRef);
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, uid);
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

  /// CHECK IF PHONE IS REGISTERED
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('phone', whereIn: [phone, _normalizePhone(phone), '+${_normalizePhone(phone)}', '0${_normalizePhone(phone).substring(2)}'])
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Check phone registered error: $e');
      return false;
    }
  }

  /// VERIFY PHONE NUMBER
  Future<void> verifyPhone(
    String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  }) async {
    try {
      bool hasReplied = false;

      // Add a fallback timeout in case Firebase backend silently hangs after reCAPTCHA
      Future.delayed(const Duration(seconds: 45), () {
        if (!hasReplied) {
          hasReplied = true;
          onError('Quá thời gian chờ phản hồi từ máy chủ. Vui lòng thử lại.');
        }
      });

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 40),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // AUTO VERIFICATION (mostly Android, or iOS test numbers)
          if (!hasReplied) {
            hasReplied = true;
            try {
              // Sign in immediately using the auto-retrieved credential
              final result = await _firebaseAuth.signInWithCredential(credential);
              final user = result.user!;
              
              // Ensure profile exists for the auto-verified user
              final profile = await getUserProfile(user.uid);
              if (profile == null) {
                final newUser = UserModel(
                  id: user.uid,
                  email: user.email ?? '',
                  name: user.displayName ?? 'Người dùng mới',
                  phone: user.phoneNumber ?? phone,
                  role: 'patient',
                  createdAt: DateTime.now(),
                );
                await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
              }
              onAutoVerified();
            } catch (e) {
              onError('Lỗi tự động xác thực: ${e.toString()}');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!hasReplied) {
            hasReplied = true;
            onError(_handleAuthError(e.code));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!hasReplied) {
            hasReplied = true;
            onCodeSent(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
        },
      );
    } catch (e) {
      onError('Lỗi hệ thống khi gửi OTP: ${e.toString()}');
    }
  }

  /// SIGN IN WITH PHONE
  Future<UserModel> signInWithPhone({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    try {
      User user;
      String phoneValue = '';

      // LUỒNG FIREBASE SMS THỰC TẾ VÀ TEST NUMBERS
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      user = result.user!;
      phoneValue = user.phoneNumber ?? '';
      // Check if profile exists
      final profile = await getUserProfile(user.uid);
      if (profile != null) return profile;

      // If NEW user, create profile with displayName
      final newUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: displayName ?? user.displayName ?? 'Người dùng mới',
        phone: phoneValue.isNotEmpty ? phoneValue : user.phoneNumber ?? '',
        role: 'patient',
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());
        
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
      } catch (e) {
        debugPrint('Firestore save profile error: $e');
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Xác thực OTP thất bại: ${e.toString()}');
    }
  }

  /// CREATE PASSWORD (Link Phone Auth with Email/Password)
  Future<void> createPassword(String phone, String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Không có người dùng nào đang đăng nhập');
    }

    final normalizedPhone = _normalizePhone(phone);
    final fakeEmail = '$normalizedPhone@smartclinic.com';
    final credential = EmailAuthProvider.credential(
      email: fakeEmail,
      password: password,
    );

    try {
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' || e.code == 'email-already-in-use') {
        throw Exception('Tài khoản này đã có mật khẩu.');
      } else if (e.code == 'provider-already-linked') {
        throw Exception('Tài khoản này đã có mật khẩu.');
      }
      throw Exception('Lỗi Firebase: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi tạo mật khẩu: $e');
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
      case 'invalid-verification-code':
        return 'Mã OTP chưa chính xác';
      case 'invalid-verification-id':
        return 'Yêu cầu xác thực đã hết hạn';
      case 'session-expired':
        return 'Phiên làm việc đã hết hạn. Vui lòng gửi lại mã.';
      case 'quota-exceeded':
        return 'Đã vượt quá số lượng tin nhắn SMS cho phép hôm nay.';
      default:
        return 'Lỗi xác thực ($code)';
    }
  }
}

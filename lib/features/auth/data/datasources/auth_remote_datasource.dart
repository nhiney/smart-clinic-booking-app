import 'dart:math';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/services/local_account_store.dart';

@lazySingleton
class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const String _biometricCredentialKey = 'auth_biometric_credential_v1';
  static const String _sessionUidKey = 'session_uid';
  static const String _sessionTokenKey = 'session_token';
  static const String _registrationPhoneKey = 'reg_phone';
  static const String _registrationPasswordKey = 'reg_password';

  String _normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('84') && clean.length > 10) return clean;
    if (clean.startsWith('0') && clean.length == 10) return '84${clean.substring(1)}';
    if (clean.length == 11 && clean.startsWith('84')) return clean;
    if (clean.length == 9) return '84$clean';
    return clean;
  }

  /// LOGIN WITH VIRTUAL EMAIL + PASSWORD
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
    String? requiredRole,
  }) async {
    try {
      debugPrint('[AUTH] Login attempt: $email');

      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user!;

      Map<String, dynamic>? userData;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) userData = doc.data();
      } catch (e) {
        debugPrint('[AUTH] Firestore profile fetch error: $e');
        if (!email.endsWith('@icare.patient') &&
            !['admin@icare.com', 'annv.choray@icare.com'].contains(email)) {
          rethrow;
        }
      }

      // Auto-create profile for virtual patient email if missing
      if (userData == null && email.endsWith('@icare.patient')) {
        final phonePrefix = email.split('@').first;
        userData = {
          'email': email,
          'role': 'patient',
          'name': 'Bệnh nhân',
          'phone': phonePrefix,
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
      }

      // Auto-recreate Firestore profile for seeded staff accounts whose document
      // may have been deleted or was never written under the real Firebase UID.
      const staffEmails = ['admin@icare.com', 'annv.choray@icare.com'];
      if (userData == null && staffEmails.contains(email)) {
        final isAdmin = email == 'admin@icare.com';
        // Use Timestamp.now() (not FieldValue.serverTimestamp) so the same map
        // can be safely passed to UserModel.fromJson which casts created_at to Timestamp.
        final profileData = {
          'email': email,
          'role': isAdmin ? 'admin' : 'doctor',
          'name': isAdmin ? 'Hệ thống Quản trị' : 'BS. Nguyễn Văn An',
          'status': 'active',
          'created_at': Timestamp.now(),
        };
        await _firestore.collection('users').doc(user.uid).set(profileData);
        userData = profileData;
        debugPrint('[AUTH] Recreated missing Firestore profile for $email → ${user.uid}');
      }

      if (userData == null) {
        await _firebaseAuth.signOut();
        throw Exception('Không tìm thấy hồ sơ tài khoản.');
      }

      final userModel = UserModel.fromJson(userData, user.uid);

      if (requiredRole != null && userModel.role != requiredRole) {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản không đúng quyền truy cập.');
      } else if (requiredRole == null && email.endsWith('@icare.patient') && userModel.role != 'patient') {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản này không có quyền truy cập dành cho nhân viên y tế.');
      }

      if (userModel.status == 'suspended') {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản đã bị tạm khóa.');
      }

      await _logSession(user.uid);
      return userModel;
    } on FirebaseAuthException catch (e) {
      // Bootstrap seeded staff accounts on first run
      final seededEmails = ['admin@icare.com', 'annv.choray@icare.com'];
      if (seededEmails.contains(email) && password == 'Icare@123') {
        try {
          UserCredential? cred;
          try {
            cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
          } on FirebaseAuthException catch (ce) {
            if (ce.code == 'user-not-found' || ce.code == 'invalid-credential') {
              cred = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
            } else {
              rethrow;
            }
          }
          if (cred.user != null) {
            final uid = cred.user!.uid;
            final snap = await _firestore.collection('users').doc(uid).get();
            Map<String, dynamic> data;
            if (!snap.exists) {
              data = {
                'email': email,
                'role': email == 'admin@icare.com' ? 'admin' : 'doctor',
                'name': email == 'admin@icare.com' ? 'Hệ thống Quản trị' : 'Bác sĩ mẫu',
                'status': 'active',
                'created_at': FieldValue.serverTimestamp(),
              };
              await _firestore.collection('users').doc(uid).set(data);
            } else {
              data = snap.data()!;
            }
            return UserModel.fromJson(data, uid);
          }
        } catch (bootstrapErr) {
          debugPrint('[AUTH] Staff bootstrap failed: $bootstrapErr');
        }
      }
      throw Exception(_handleAuthError(e.code));
    }
  }

  /// CREATE DOCTOR ACCOUNT (Admin action)
  Future<UserModel> createDoctorAccount({
    required String fullName,
    required String hospitalId,
    required String hospitalName,
    required String departmentId,
    String? phone,
    String specialty = '',
    int experienceYears = 0,
    String bio = '',
    String address = '',
  }) async {
    final email = _generateDoctorEmail(fullName, hospitalName);
    const defaultPassword = 'Icare@123';

    try {
      final secondaryAppName = 'SecondaryAuthApp_${DateTime.now().millisecondsSinceEpoch}';
      final secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: _firebaseAuth.app.options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final result = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: defaultPassword,
      );
      final uid = result.user!.uid;
      await secondaryApp.delete();

      final doctorModel = UserModel(
        id: uid,
        email: email,
        name: fullName,
        phone: phone ?? '',
        authProvider: 'email',
        role: 'doctor',
        tenantId: hospitalId,
        departmentId: departmentId,
        specialty: specialty,
        experienceYears: experienceYears,
        bio: bio,
        address: address,
        isVerified: true,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).set(doctorModel.toJson());
      return doctorModel;
    } catch (e) {
      throw Exception('Không thể tạo tài khoản bác sĩ: $e');
    }
  }

  String _generateDoctorEmail(String name, String hospital) {
    String slugify(String text) {
      return text.toLowerCase()
          .replaceAll(RegExp(r'[đĐ]'), 'd')
          .replaceAll(RegExp(r'[áàảãạăắằẳẵặâấầẩẫậ]'), 'a')
          .replaceAll(RegExp(r'[éèẻẽẹêếềểễệ]'), 'e')
          .replaceAll(RegExp(r'[íìỉĩị]'), 'i')
          .replaceAll(RegExp(r'[óòỏõọôốồổỗộơớờởỡợ]'), 'o')
          .replaceAll(RegExp(r'[úùủũụưứừửữự]'), 'u')
          .replaceAll(RegExp(r'[ýỳỷỹỵ]'), 'y')
          .replaceAll(RegExp(r'\s+'), '');
    }
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'doctor@icare.com';
    final lastName = slugify(parts.last);
    String initials = '';
    for (int i = 0; i < parts.length - 1; i++) {
      if (parts[i].isNotEmpty) initials += slugify(parts[i][0]);
    }
    return '$lastName$initials.${slugify(hospital)}@icare.com';
  }

  /// REGISTER (Patient initial setup after OTP verification)
  Future<UserModel> register({
    required String name,
    required String phone,
    required String role,
    String? email,
    String? password,
    String? tenantId,
  }) async {
    final user = _firebaseAuth.currentUser;
    debugPrint('[AUTH] Register called. UID: ${user?.uid ?? 'NULL'}');

    // In debug mode the mock OTP flow never creates a real Firebase user.
    // Build the user from the predictable mock UID and save to Firestore directly.
    if (user == null && kDebugMode) {
      final normalized = _normalizePhone(phone);
      final mockUid = 'MOCK_USER_mock_vid_$normalized';
      final mockModel = UserModel(
        id: mockUid,
        email: email ?? '$normalized@icare.patient',
        name: name,
        phone: phone,
        authProvider: 'phone',
        role: role,
        tenantId: tenantId,
        isVerified: role == 'patient',
        status: 'active',
        password: password,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      try {
        final data = mockModel.toJson();
        data['uid'] = mockUid;
        await _firestore.collection('users').doc(mockUid).set(data, SetOptions(merge: true));
        await _firestore.collection('registered_phones').doc(normalized).set({
          'uid': mockUid,
          'created_at': FieldValue.serverTimestamp(),
        });
        debugPrint('[AUTH] Mock register saved. UID: $mockUid');
      } catch (e) {
        debugPrint('[AUTH] Mock register Firestore error (non-fatal): $e');
      }
      return mockModel;
    }

    if (user == null) {
      throw Exception('Chưa xác thực Firebase. Vui lòng thử lại từ đầu.');
    }

    String? linkedVirtualEmail;
    if (password != null) {
      final normalized = _normalizePhone(phone);
      final virtualEmail = '$normalized@icare.patient';
      linkedVirtualEmail = virtualEmail;
      try {
        final credential = EmailAuthProvider.credential(email: virtualEmail, password: password);
        await user.linkWithCredential(credential);
        await user.reload();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
          throw Exception('Số điện thoại đã được đăng ký.');
        }
        if (e.code != 'provider-already-linked') rethrow;
      }
    }

    final effectiveEmail = email ?? _firebaseAuth.currentUser?.email ?? linkedVirtualEmail ?? '';
    final userModel = UserModel(
      id: user.uid,
      email: effectiveEmail,
      name: name,
      phone: phone,
      authProvider: user.phoneNumber != null ? 'phone' : 'email',
      role: role,
      tenantId: tenantId,
      isVerified: role == 'patient',
      status: 'active',
      password: password,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // 0. KHÔNG CHO ĐĂNG KÝ TRÙNG SỐ ĐIỆN THOẠI
      final normalized = _normalizePhone(phone);
      final exists = await isPhoneRegistered(normalized);
      if (exists) {
        throw Exception('Số điện thoại này đã được đăng ký trên hệ thống.');
      }

      final data = userModel.toJson();
      data['uid'] = user.uid;

      // 1. Save user profile to Firestore
      await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));

      // 2. Mark phone as registered for duplicate prevention (Server-side)
      await _firestore.collection('registered_phones').doc(normalized).set({
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 3. SAVE LOCALLY (Persistent across app restarts)
      await LocalAccountStore.instance.saveAccount(
        phone: phone,
        password: password ?? '',
        name: name,
      );

      await _logAudit(user.uid, 'REGISTER', 'Registered with role: $role');
      return userModel;
    } catch (e) {
      debugPrint('[AUTH] Register save error: $e');
      if (e.toString().contains('đã được đăng ký')) rethrow;
      throw Exception('Lưu hồ sơ thất bại: $e');
    }
  }

  /// CHECK IF PHONE IS ALREADY REGISTERED
  /// Ưu tiên LocalAccountStore (SharedPreferences) — hoạt động offline,
  /// fallback về Firestore nếu không tìm thấy ở local.
  Future<bool> isPhoneRegistered(String phone) async {
    // 1. Kiểm tra local trước — nhanh, không cần mạng
    final localFound = await LocalAccountStore.instance.isPhoneRegistered(phone);
    if (localFound) return true;

    // 2. Fallback Firestore
    try {
      final normalized = _normalizePhone(phone);
      final ref = _firestore.collection('registered_phones').doc(normalized);
      try {
        final cached = await ref.get(const GetOptions(source: Source.cache));
        if (cached.exists) return true;
      } catch (_) {}
      final doc = await ref
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 3));
      return doc.exists;
    } catch (e) {
      debugPrint('[AUTH] isPhoneRegistered Firestore error: $e');
      return false;
    }
  }

  /// CREATE QR LOGIN TOKEN — stored in Firestore, no Cloud Functions needed
  Future<Map<String, dynamic>> createQrLoginToken({
    bool persistent = false,
    String? targetUid,
  }) async {
    final user = _firebaseAuth.currentUser;

    // Mock fallback: debug mode với mock user (Firebase currentUser == null)
    if (user == null && kDebugMode) {
      debugPrint('[AUTH] createQrLoginToken — mock mode, trả về token giả');
      final mockToken = 'mock_qr_${DateTime.now().millisecondsSinceEpoch}';
      final expiresAt = persistent
          ? DateTime.now().add(const Duration(days: 3650))
          : DateTime.now().add(const Duration(days: 30));
      return {'token': mockToken, 'expiresAt': expiresAt.toIso8601String()};
    }

    if (user == null) throw Exception('Bạn cần đăng nhập trên thiết bị tạo QR.');

    final uid = targetUid ?? user.uid;

    // Get the virtual email from Firebase Auth
    final userEmail = _firebaseAuth.currentUser?.email;

    // Get the stored password from Firestore user document
    String? storedPassword;
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        storedPassword = userDoc.data()?['password'] as String?;
      }
    } catch (e) {
      debugPrint('[AUTH] Could not fetch user password for QR: $e');
    }

    if (userEmail == null || userEmail.isEmpty) {
      throw Exception('Không thể xác định email tài khoản để tạo QR.');
    }
    if (storedPassword == null || storedPassword.isEmpty) {
      throw Exception('Không tìm thấy mật khẩu đã lưu. Vui lòng đặt lại mật khẩu.');
    }

    final token = _uuid.v4();
    final expiresAt = persistent
        ? DateTime.now().add(const Duration(days: 3650))
        : DateTime.now().add(const Duration(days: 30));

    await _firestore.collection('qr_tokens').doc(token).set({
      'uid': uid,
      'email': userEmail,
      'password': storedPassword,
      'expires_at': Timestamp.fromDate(expiresAt),
      'created_at': FieldValue.serverTimestamp(),
    });

    // Save token reference on user doc for management
    await _firestore.collection('users').doc(uid).update({'qr_token': token});

    return {
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// SIGN IN WITH QR TOKEN — reads from Firestore, signs in with stored credentials
  Future<UserModel> signInWithQrToken(String qrToken) async {
    try {
      debugPrint('[AUTH] QR login with token: $qrToken');

      // 1. Look up token (qr_tokens must allow public read in Firestore rules)
      final tokenDoc = await _firestore.collection('qr_tokens').doc(qrToken).get();
      if (!tokenDoc.exists) throw Exception('Mã QR không hợp lệ hoặc đã hết hạn.');

      final tokenData = tokenDoc.data()!;

      // 2. Check expiry
      final expiresAt = tokenData['expires_at'] as Timestamp?;
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        throw Exception('Mã QR đã hết hạn. Vui lòng tạo mã mới.');
      }

      final email = tokenData['email'] as String?;
      final password = tokenData['password'] as String?;
      final uid = tokenData['uid'] as String?;

      if (email == null || email.isEmpty || password == null || password.isEmpty || uid == null) {
        throw Exception('Dữ liệu mã QR không đầy đủ.');
      }

      // 3. Sign in with stored credentials
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = result.user!;

      // 4. Fetch user profile
      final profile = await getUserProfile(firebaseUser.uid);
      if (profile == null) throw Exception('Không tìm thấy hồ sơ người dùng.');

      if (profile.status == 'suspended') {
        await logout();
        throw Exception('Tài khoản đã bị tạm khóa.');
      }

      await _logSession(firebaseUser.uid);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      if (e.toString().startsWith('Exception:')) rethrow;
      throw Exception('Đăng nhập QR thất bại: $e');
    }
  }

  /// LOG SESSION
  Future<void> _logSession(String uid) async {
    try {
      await _firestore.collection('sessions').add({
        'user_id': uid,
        'device': kIsWeb ? 'Web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'iOS' : 'Android'),
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      });
      await _logAudit(uid, 'LOGIN', 'User logged in');
    } catch (e) {
      debugPrint('[AUTH] Log session error: $e');
    }
  }

  Future<void> _logAudit(String uid, String action, String details) async {
    try {
      await _firestore.collection('audit_logs').add({
        'user_id': uid,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[AUTH] Log audit error: $e');
    }
  }

  Future<void> saveSession(UserEntity user) async {
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken() ?? '';
      await _secureStorage.write(key: _sessionUidKey, value: user.id);
      await _secureStorage.write(key: _sessionTokenKey, value: token);
    } catch (e) {
      debugPrint('[AUTH] Save session error: $e');
    }
  }

  Future<void> saveRegistrationLocally(String phone, String password) async {
    try {
      await _secureStorage.write(key: _registrationPhoneKey, value: phone);
      await _secureStorage.write(key: _registrationPasswordKey, value: password);
    } catch (e) {
      debugPrint('[AUTH] Save registration locally error: $e');
    }
  }

  Future<Map<String, String>?> getLocalRegistrationInfo() async {
    try {
      final phone = await _secureStorage.read(key: _registrationPhoneKey);
      final password = await _secureStorage.read(key: _registrationPasswordKey);
      if (phone != null && password != null) return {'phone': phone, 'password': password};
    } catch (e) {
      debugPrint('[AUTH] Get local registration info error: $e');
    }
    return null;
  }

  Future<bool> hasSavedSession() async {
    try {
      final uid = await _secureStorage.read(key: _sessionUidKey);
      final token = await _secureStorage.read(key: _sessionTokenKey);
      return uid != null && uid.isNotEmpty && token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearSession() async {
    try {
      await _firebaseAuth.signOut();
      await _secureStorage.delete(key: _sessionUidKey);
      await _secureStorage.delete(key: _sessionTokenKey);
    } catch (e) {
      debugPrint('[AUTH] Clear session error: $e');
    }
  }

  Future<void> logout() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) await _logAudit(user.uid, 'LOGOUT', 'User logged out');
    await _firebaseAuth.signOut();
    await clearSession();
  }

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<DocumentSnapshot> _fetchWithRetry(DocumentReference docRef, {int maxAttempts = 3}) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        return await docRef.get(const GetOptions(source: Source.serverAndCache));
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts || !e.toString().contains('unavailable')) rethrow;
        await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
      }
    }
    throw Exception('Không thể kết nối máy chủ sau nhiều lần thử.');
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _fetchWithRetry(_firestore.collection('users').doc(uid));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      debugPrint('[AUTH] getUserProfile error: $e');
    }
    return null;
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      final data = user.toJson();
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(user.id).update(data);
    } catch (e) {
      throw Exception('Cập nhật hồ sơ thất bại');
    }
  }

  /// VERIFY PHONE NUMBER (OTP via Firebase Phone Auth)
  Future<void> verifyPhone(
    String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  }) async {
    try {
      debugPrint('[AUTH] Bắt đầu xác thực số điện thoại Firebase: $phone');
      bool hasReplied = false;

      String formatted = phone.trim();
      if (!formatted.startsWith('+')) {
        if (formatted.startsWith('0')) {
          formatted = '+84${formatted.substring(1)}';
        } else if (formatted.startsWith('84')) {
          formatted = '+$formatted';
        } else {
          formatted = '+84$formatted';
        }
      }

      debugPrint('[AUTH] Dữ liệu số điện thoại gửi đi: $formatted');

      debugPrint('[AUTH] Đang gửi yêu cầu OTP cho: $formatted');

      // --- GỌI FIREBASE PHONE AUTH THẬT ---
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formatted,
        timeout: const Duration(seconds: 120), // Tăng timeout cho mạng yếu
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (hasReplied) return;
          hasReplied = true;
          try {
            final result = await _firebaseAuth.signInWithCredential(credential);
            final user = result.user!;
            final profile = await getUserProfile(user.uid);
            if (profile == null) {
              await _firestore.collection('users').doc(user.uid).set(UserModel(
                id: user.uid,
                name: 'Người dùng mới',
                phone: user.phoneNumber ?? formatted,
                authProvider: 'phone',
                role: 'patient',
                status: 'active',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ).toJson());
            }
            onAutoVerified();
          } catch (e) {
            onError('Lỗi tự động xác thực: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (hasReplied) return;
          hasReplied = true;
          debugPrint('[AUTH] Firebase Auth Error (${e.code}): ${e.message}');
          onError(_handleAuthError(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (hasReplied) return;
          hasReplied = true;
          debugPrint('[AUTH] OTP đã gửi. verificationId: $verificationId');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('[AUTH] Hết thời gian tự động lấy OTP: $verificationId');
        },
      );
    } catch (e) {
      debugPrint('[AUTH] Lỗi ném ra từ verifyPhoneNumber: $e');
      onError('Lỗi hệ thống khi gửi OTP: $e');
    }
  }

  /// SIGN IN WITH PHONE OTP
  Future<UserModel> signInWithPhone({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    try {
      debugPrint('[AUTH] Đang xác thực OTP: $smsCode cho ID: $verificationId');
      
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = result.user!;
      final phoneValue = firebaseUser.phoneNumber ?? '';

      final profile = await getUserProfile(firebaseUser.uid);
      if (profile != null) {
        if (profile.status == 'suspended') {
          await logout();
          throw Exception('Tài khoản đã bị tạm khóa.');
        }
        await _logSession(firebaseUser.uid);
        return profile;
      }

      final newUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: displayName ?? firebaseUser.displayName ?? 'Người dùng mới',
        phone: phoneValue,
        authProvider: 'phone',
        role: 'patient',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
      await _logSession(firebaseUser.uid);
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception('Xác thực OTP thất bại: $e');
    }
  }

  // ── Biometrics ──────────────────────────────────────────────────────────────

  Future<bool> isBiometricAvailable() async {
    try {
      return (await _localAuth.canCheckBiometrics) && (await _localAuth.isDeviceSupported());
    } catch (_) {
      return false;
    }
  }

  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  }) async {
    final payload = jsonEncode({
      'identifier': identifier,
      'password': password,
      'requiredRole': requiredRole,
    });
    await _secureStorage.write(key: _biometricCredentialKey, value: payload);
  }

  Future<void> clearBiometricCredential() async {
    await _secureStorage.delete(key: _biometricCredentialKey);
  }

  Future<bool> isBiometricEnabled() async {
    final raw = await _secureStorage.read(key: _biometricCredentialKey);
    return raw != null && raw.isNotEmpty;
  }

  Future<UserModel> loginWithBiometrics() async {
    if (!await isBiometricAvailable()) throw Exception('Thiết bị chưa hỗ trợ sinh trắc học.');

    final didAuth = await _localAuth.authenticate(
      localizedReason: 'Xác thực để đăng nhập ICare',
      biometricOnly: true,
    );
    if (!didAuth) throw Exception('Xác thực sinh trắc học thất bại.');

    final raw = await _secureStorage.read(key: _biometricCredentialKey);
    if (raw == null || raw.isEmpty) throw Exception('Bạn chưa bật đăng nhập sinh trắc học.');

    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final identifier = data['identifier']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';
    final requiredRole = data['requiredRole']?.toString();
    if (identifier.isEmpty || password.isEmpty) throw Exception('Dữ liệu sinh trắc học không hợp lệ.');

    return loginWithEmail(
      email: identifier,
      password: password,
      requiredRole: requiredRole?.isEmpty == true ? null : requiredRole,
    );
  }

  // ── Error handling ───────────────────────────────────────────────────────────

  String _handleAuthError(String code) {
    debugPrint('[AUTH] Firebase Auth Error Code: $code');
    switch (code) {
      case 'user-not-found':
        return 'Số điện thoại chưa được đăng ký.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'invalid-credential':
        return 'Số điện thoại hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Số điện thoại đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng.';
      case 'invalid-verification-code':
        return 'Mã OTP không chính xác.';
      case 'invalid-verification-id':
        return 'Yêu cầu xác thực đã hết hạn.';
      case 'session-expired':
        return 'Phiên xác thực đã hết hạn. Vui lòng gửi lại OTP.';
      default:
        return 'Lỗi xác thực ($code).';
    }
  }
}

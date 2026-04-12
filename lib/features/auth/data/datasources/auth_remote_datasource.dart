import 'dart:math';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/config/debug_test_login_config.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

@lazySingleton
class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Environment Config for Clean Architecture
  final bool isMockMode = kDebugMode;
  String? _lastPhoneForMock;
  UserModel? _lastMockUser;
  final Map<String, String> _mockCredentialStore = {};
  static const String _biometricCredentialKey = 'auth_biometric_credential_v1';
  static const String _sessionUidKey = 'session_uid';
  static const String _sessionTokenKey = 'session_token';
  static const String _registrationPhoneKey = 'reg_phone';
  static const String _registrationPasswordKey = 'reg_password';

  /// Normalizes phone number to digits-only format, replacing leading 0 or +84 with 84 for VN
  String _normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    // Handle cases like +84 or 84 prefixing
    if (clean.startsWith('84') && clean.length > 10) {
      return clean;
    }
    if (clean.startsWith('0') && clean.length == 10) {
      return '84${clean.substring(1)}';
    }
    // If it's already 84 + 9 digits (total 11)
    if (clean.length == 11 && clean.startsWith('84')) {
      return clean;
    }
    // If it's 9 digits, assume VN and add 84
    if (clean.length == 9) {
      return '84$clean';
    }
    return clean;
  }

  /// LOGIN WITH EMAIL/VIRTUAL EMAIL
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
    String? requiredRole,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[AUTH] Attempting login with: $email');
        
        final normalizedTarget = email.split('@').first;

        // 0. CHECK HARDCODED DEBUG SEED (User's account)
        if ((normalizedTarget == '84326583876' || normalizedTarget == '326583876') && password == 'Nhi@1234') {
            debugPrint('[AUTH] Debug Seed Login Success for: $email');
            return _createMockUser('84326583876@icare.patient');
        }

        // 1. CHECK MOCK STORE FIRST (Memory)
        if (_mockCredentialStore.containsKey(email)) {
          final mockPassword = _mockCredentialStore[email];
          if (mockPassword == password) {
            debugPrint('[AUTH] Mock Login Success (Memory) for: $email');
            return _createMockUser(email);
          }
        }
        
        // 2. FAILOVER TO SECURE STORAGE (for persistence across restarts)
        final localPhone = await _secureStorage.read(key: _registrationPhoneKey);
        final localPass = await _secureStorage.read(key: _registrationPasswordKey);
        if (localPhone != null && localPass != null) {
          final normalizedLocal = _normalizePhone(localPhone);
          // Compare normalized versions to be safe
          if (normalizedLocal == normalizedTarget && localPass == password) {
            debugPrint('[AUTH] Mock Login Success (Storage) for: $email');
            return _createMockUser(email);
          }
        }
      }
      
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      
      // Get user profile to check role
      Map<String, dynamic>? userData;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          userData = doc.data();
        }
      } catch (firestoreError) {
        debugPrint('[AUTH] Firestore profile fetch failed: $firestoreError');
        // If it's a seed account, we will handle it in the bootstrap/fallback logic
        if (!['admin@icare.com', 'annv.choray@icare.com'].contains(email) &&
            !email.endsWith('@icare.patient')) {
          rethrow;
        }
      }

      if (userData == null && email.endsWith('@icare.patient')) {
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'role': 'patient',
            'name': 'Bệnh nhân',
            'phone': email.split('@').first,
            'status': 'active',
            'created_at': FieldValue.serverTimestamp(),
          });
          final snap = await _firestore.collection('users').doc(user.uid).get();
          userData = snap.data();
        } catch (bootstrapErr) {
          debugPrint('[AUTH] Không tạo được hồ sơ BN trên Firestore: $bootstrapErr');
        }
      }

      if (userData == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'Triggering bootstrap for seed account');
      }
      
      final userModel = UserModel.fromJson(userData, user.uid);
      
      // RBAC Check
      if (requiredRole != null) {
        if (userModel.role != requiredRole) {
          await _firebaseAuth.signOut();
          throw Exception('Tài khoản không đúng quyền truy cập: Yêu cầu $requiredRole.');
        }
      } else {
        final isPatientAppLogin = email.endsWith('@icare.patient');
        if (userModel.role == 'patient' && !isPatientAppLogin) {
          await _firebaseAuth.signOut();
          throw Exception('Tài khoản này không có quyền truy cập dành cho nhân viên y tế.');
        }
      }

      if (userModel.status == 'suspended') {
        await _firebaseAuth.signOut();
        throw Exception('Tài khoản đã bị tạm khóa.');
      }

      // Log session
      await _logSession(user.uid);
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      // REQUIREMENT: Auto-Hydration for Seeded Accounts (Admin/Doctor)
      final seededEmails = ['admin@icare.com', 'annv.choray@icare.com'];
      if (seededEmails.contains(email) && password == 'Icare@123') {
        try {
          // 1. Try to sign in or create account on Auth FIRST
          // This gives us the auth context (request.auth) needed for Firestore rules
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
            final realUid = cred.user!.uid;
            
            // 2. NOW we have permission to check/create Firestore metadata
            // OPTIMIZATION: Use .doc(uid).get() instead of .where() for better permission clearance
            final docSnapshot = await _firestore.collection('users').doc(realUid).get();
            
            Map<String, dynamic> data;
            if (!docSnapshot.exists) {
              // Try searching by email as fallback if doc ID doesn't match for some reason
              final emailQuery = await _firestore.collection('users')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();
              
              if (emailQuery.docs.isEmpty) {
                // Create Bootstrap Metadata
                data = {
                  'email': email,
                  'role': email == 'admin@icare.com' ? 'admin' : 'doctor',
                  'name': email == 'admin@icare.com' ? 'Hệ thống Quản trị' : 'Bác sĩ mẫu',
                  'status': 'active',
                  'created_at': FieldValue.serverTimestamp(),
                };
                await _firestore.collection('users').doc(realUid).set(data);
              } else {
                data = emailQuery.docs.first.data();
                // Link existing metadata to new UID
                await _firestore.collection('users').doc(realUid).set(data, SetOptions(merge: true));
              }
            } else {
              data = docSnapshot.data()!;
            }
            
            return UserModel.fromJson(data, realUid);
          }
        } catch (hydrationError) {
          debugPrint('Bootstrap/Hydration failed: $hydrationError');
          // Fall through to standard error handling if bootstrap fails
        }
      }

      // Debug: tạo Auth + Firestore cho tài khoản BN test nếu chưa tồn tại (chỉ khi thiếu user / sai credential lưu)
      if (kDebugMode &&
          email == DebugTestLoginConfig.patientVirtualEmail &&
          password == DebugTestLoginConfig.patientPassword &&
          (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
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
            final realUid = cred.user!.uid;
            final docSnapshot = await _firestore.collection('users').doc(realUid).get();

            Map<String, dynamic> data;
            if (!docSnapshot.exists) {
              data = {
                'email': email,
                'role': 'patient',
                'name': 'BN Test ICare',
                'phone': '84912345678',
                'status': 'active',
                'created_at': FieldValue.serverTimestamp(),
              };
              await _firestore.collection('users').doc(realUid).set(data);
            } else {
              data = docSnapshot.data()!;
            }

            await _logSession(realUid);
            return UserModel.fromJson(data, realUid);
          }
        } catch (hydrationError) {
          debugPrint('[AUTH] Debug patient bootstrap failed: $hydrationError');
        }
      }

      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<UserModel> _createMockUser(String email) async {
    final phone = email.split('@').first;
    final mockUid = 'MOCK_USER_$phone';
    
    // Only try fetching from Firestore if we have a real session and permissions
    // Mock users usually don't have permissions unless signed into Firebase Auth
    if (_firebaseAuth.currentUser != null) {
      try {
        final docSnapshot = await _firestore.collection('users').doc(mockUid).get();
        if (docSnapshot.exists) {
          return UserModel.fromJson(docSnapshot.data()!, mockUid);
        }
      } catch (e) {
        // Suppress permission-denied for mocks
        if (!e.toString().contains('permission-denied')) {
          debugPrint('[AUTH] Mock Firestore fetch failed: $e');
        }
      }
    }
    
    // Fallback if metadata not in firestore yet
    return UserModel(
      id: mockUid,
      email: email,
      name: email.contains('84326583876') ? 'Nhi Yến' : 'BN Test (Mock)',
      phone: phone,
      authProvider: 'email',
      role: 'patient',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create Doctor Account (Admin action)
  /// Uses a secondary Firebase App to create the user without signing out the Admin.
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
      // 1. Create Auth User using Secondary App
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
      
      final newUser = result.user!;
      final uid = newUser.uid;
      
      // Clean up secondary app
      await secondaryApp.delete();

      // 2. Save Profile in Firestore
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
      debugPrint('[AUTH] Create doctor failed: $e');
      throw Exception('Không thể tạo tài khoản bác sĩ: $e');
    }
  }

  String _generateDoctorEmail(String name, String hospital) {
    // Basic logic: last word (name) + initials + dot + hospital slug + @icare.com
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
      if (parts[i].isNotEmpty) {
        initials += slugify(parts[i][0]);
      }
    }

    final hospitalSlug = slugify(hospital);
    return '$lastName$initials.$hospitalSlug@icare.com';
  }

  /// REGISTER (Patient initial setup)
  Future<UserModel> register({
    required String name,
    required String phone,
    required String role,
    String? email,
    String? password,
    String? tenantId,
  }) async {
    final user = _firebaseAuth.currentUser;
    debugPrint('[AUTH] Register called. Current User: ${user?.uid ?? 'NULL'}');
    
    // Support for Debug/Mock mode
    if (isMockMode && _lastMockUser != null && _normalizePhone(_lastMockUser!.phone) == _normalizePhone(phone)) {
      debugPrint('[AUTH] Registering in Mock Mode for: $phone');
      final updatedUser = _lastMockUser!.copyWith(
        name: name,
        role: role,
        tenantId: tenantId,
      );
      _lastMockUser = updatedUser;

      // Persistence for Virtual Email login in Mock mode
      if (password != null) {
        final normalized = _normalizePhone(phone);
        final virtualEmail = "$normalized@icare.patient";
        _mockCredentialStore[virtualEmail] = password;
        debugPrint('[AUTH] Saved Mock Credentials for: $virtualEmail');
      }

      // Save to Firestore so profile persists for Home screen
      try {
        await _firestore.collection('users').doc(updatedUser.id).set(updatedUser.toJson(), SetOptions(merge: true));
        debugPrint('[AUTH] Mock Profile saved to Firestore: ${updatedUser.id}');
      } catch (e) {
        debugPrint('[AUTH] Mock Profile Firestore save failed: $e');
      }

      return updatedUser;
    }

    if (user == null) {
      debugPrint('[AUTH] CRITICAL: No active Firebase session during registration.');
      throw Exception('Chưa xác thực Firebase Auth. Vui lòng thử lại.');
    }

    // If password provided, link with email/password (Virtual Email)
    String? linkedVirtualEmail;
    if (password != null) {
      final normalized = _normalizePhone(phone);
      final virtualEmail = "$normalized@icare.patient";
      linkedVirtualEmail = virtualEmail;
      try {
        final credential = EmailAuthProvider.credential(email: virtualEmail, password: password);
        await user.linkWithCredential(credential);
        await user.reload();
      } catch (e) {
        debugPrint('Link credential error (might already exist): $e');
        if (e is FirebaseAuthException) {
          // This is the reliable way to block reusing an already-registered phone:
          // virtualEmail is derived from phone, so if it's already in use => phone already registered.
          if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
            throw Exception('Số điện thoại đã được đăng ký.');
          }
          if (e.code == 'provider-already-linked') {
            // Already linked; continue.
          }
        }
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final data = userModel.toJson();
      data['uid'] = user.uid;
      data['email'] = userModel.email.isNotEmpty ? userModel.email : (user.email ?? '');
      data['name'] = userModel.name;
      data['role'] = userModel.role;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
      
      await _logAudit(user.uid, 'REGISTER', 'User registered with role: $role');
      
      return userModel;
    } catch (e) {
      debugPrint('Register error: $e');
      throw Exception('Lưu hồ sơ thất bại: ${e.toString()}');
    }
  }

  /// LOG SESSION
  Future<void> _logSession(String uid) async {
    try {
      final sessionDoc = _firestore.collection('sessions').doc();
      await sessionDoc.set({
        'user_id': uid,
        'device': kIsWeb ? 'Web Browser' : (defaultTargetPlatform == TargetPlatform.iOS ? 'iOS Device' : 'Android Device'),
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      });
      
      await _logAudit(uid, 'LOGIN', 'User logged in');
    } catch (e) {
      debugPrint('Log session error: $e');
    }
  }

  /// LOG AUDIT
  Future<void> _logAudit(String uid, String action, String details) async {
    try {
      await _firestore.collection('audit_logs').add({
        'user_id': uid,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Log audit error: $e');
    }
  }

  Future<void> saveSession(UserEntity user) async {
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken() ?? 'local_session';
      await _secureStorage.write(key: _sessionUidKey, value: user.id);
      await _secureStorage.write(key: _sessionTokenKey, value: token);
    } catch (e) {
      debugPrint('Save session error: $e');
    }
  }

  Future<void> saveRegistrationLocally(String phone, String password) async {
    try {
      await _secureStorage.write(key: _registrationPhoneKey, value: phone);
      await _secureStorage.write(key: _registrationPasswordKey, value: password);
    } catch (e) {
      debugPrint('Save registration locally error: $e');
    }
  }

  Future<Map<String, String>?> getLocalRegistrationInfo() async {
    try {
      final phone = await _secureStorage.read(key: _registrationPhoneKey);
      final password = await _secureStorage.read(key: _registrationPasswordKey);
      if (phone != null && password != null) {
        return {'phone': phone, 'password': password};
      }
    } catch (e) {
      debugPrint('Get local registration info error: $e');
    }
    return null;
  }

  Future<bool> hasSavedSession() async {
    try {
      final uid = await _secureStorage.read(key: _sessionUidKey);
      final token = await _secureStorage.read(key: _sessionTokenKey);
      return (uid != null && uid.isNotEmpty) && (token != null && token.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  /// CLEAR SESSION (Public for Clean Architecture)
  Future<void> clearSession() async {
    try {
      // 1. Sign out from Firebase Auth
      await _firebaseAuth.signOut();
      
      // 2. Clear local secure storage
      await _secureStorage.delete(key: _sessionUidKey);
      await _secureStorage.delete(key: _sessionTokenKey);
      
      debugPrint('[AUTH] Session cleared successfully');
    } catch (e) {
      debugPrint('Clear session error: $e');
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _logAudit(user.uid, 'LOGOUT', 'User logged out');
    }
    await _firebaseAuth.signOut();
    await clearSession();
  }

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();

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
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    throw Exception("Không thể kết nối máy chủ sau nhiều lần thử.");
  }
  Future<UserModel?> getUserProfile(String uid) async {
    // 1. Handle Mock Mode
    if (isMockMode && uid.startsWith('MOCK_USER_')) {
      return _lastMockUser?.id == uid ? _lastMockUser : null;
    }

    // 2. Fetch from Firestore (Real)
    try {
      final docRef = _firestore.collection('users').doc(uid);
      // Use retry logic for stability
      final doc = await _fetchWithRetry(docRef);
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      debugPrint('[AUTH] Get user profile error: $e');
      
      // Secondary fallback for current user if network fails but local auth is still valid
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        // We can't return a full profile but we don't want to crash
        // Return null or a skeleton if necessary, here null is safer to trigger UI reload
        return null;
      }
    }
    return null;
  }

  /// UPDATE USER PROFILE
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final data = user.toJson();
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(data);
    } catch (e) {
      debugPrint('Update user profile error: $e');
      throw Exception('Cập nhật hồ sơ thất bại');
    }
  }

  /// CHECK IF PHONE IS REGISTERED
  Future<bool> isPhoneRegistered(String phone) async {
    if (isMockMode) {
      // In mock mode, we check against the last registered mock user if any
      final normalizedInput = _normalizePhone(phone);
      final normalizedMock = _lastMockUser != null ? _normalizePhone(_lastMockUser!.phone) : '';
      return normalizedInput == normalizedMock;
    }

    try {
      final normalized = _normalizePhone(phone);
      
      // Check multiple formats: 84..., +84..., 0...
      final searchTerms = [
        phone.trim(),
        normalized,
        '+$normalized',
      ];
      
      // Also add 0-prefix version if it's VN
      if (normalized.startsWith('84')) {
        searchTerms.add('0${normalized.substring(2)}');
      }

      final query = await _firestore
          .collection('users')
          .where('phone', whereIn: searchTerms.toSet().toList())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('[AUTH] Lỗi kiểm tra số điện thoại: $e');
      // In case of permission errors or others, we don't want to silently allow 
      // registration if we can't verify. But for simplicity in this dev environment,
      // we return false and let the link step catch it if necessary.
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
      
      String formattedPhone = phone.trim();
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('0')) {
          formattedPhone = '+84${formattedPhone.substring(1)}';
        } else if (!formattedPhone.startsWith('84')) {
          formattedPhone = '+84$formattedPhone';
        } else {
          formattedPhone = '+$formattedPhone';
        }
      }
      
      if (isMockMode) {
        _lastPhoneForMock = formattedPhone;
        onCodeSent('MOCK_VERIFICATION_ID');
        return;
      }
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!hasReplied) {
            hasReplied = true;
            try {
              final result = await _firebaseAuth.signInWithCredential(credential);
              final user = result.user!;
              
              final profile = await getUserProfile(user.uid);
              if (profile == null) {
                final newUser = UserModel(
                  id: user.uid,
                  name: 'Người dùng mới',
                  phone: user.phoneNumber ?? formattedPhone,
                  authProvider: 'phone',
                  role: 'patient',
                  status: 'active',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
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
        codeAutoRetrievalTimeout: (String verificationId) {},
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
      User? firebaseUser;
      String phoneValue = '';

      if (isMockMode && verificationId == 'MOCK_VERIFICATION_ID') {
        if (smsCode != '123456') throw Exception('Mã OTP không chính xác.');
        
        phoneValue = _lastPhoneForMock ?? '';
        final mockUid = 'MOCK_USER_${phoneValue.replaceAll('+', '')}'; 
        final existing = _lastMockUser;
        if (existing != null && existing.id == mockUid) return existing;

        final newUser = UserModel(
          id: mockUid,
          name: displayName ?? 'Người dùng Test',
          phone: phoneValue,
          authProvider: 'phone',
          role: 'patient',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _lastMockUser = newUser;
        return newUser;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      firebaseUser = result.user!;
      phoneValue = firebaseUser.phoneNumber ?? '';

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
      throw Exception('Xác thực OTP thất bại: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createQrLoginToken({
    bool persistent = false,
    String? targetUid,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      if (isMockMode && (_lastMockUser != null || targetUid != null)) {
        final uid = targetUid ?? _lastMockUser?.id ?? 'unknown';
        return {
          'token': 'mock_qr_$uid',
          'expiresAt': persistent
              ? DateTime.now().add(const Duration(days: 3650)).toIso8601String()
              : DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
        };
      }
      throw Exception('Bạn cần đăng nhập trên thiết bị tạo QR.');
    }

    try {
      final callable = _functions.httpsCallable('createQrLoginToken');
      final result = await callable.call(<String, dynamic>{
        'uid': targetUid ?? user.uid,
        'persistent': persistent,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return {
        'token': data['token']?.toString() ?? '',
        'expiresAt': data['expiresAt']?.toString() ?? '',
      };
    } catch (e) {
      if (isMockMode) {
        final uid = targetUid ?? user.uid;
        return {
          'token': 'mock_qr_${uid}_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': persistent
              ? DateTime.now().add(const Duration(days: 3650)).toIso8601String()
              : DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
        };
      }
      throw Exception('Không thể tạo mã QR đăng nhập: ${e.toString()}');
    }
  }


  Future<UserModel> signInWithQrToken(String qrToken) async {
    try {
      final callable = _functions.httpsCallable('exchangeQrLoginToken');
      final result = await callable.call(<String, dynamic>{'token': qrToken});
      final data = Map<String, dynamic>.from(result.data as Map);
      final customToken = data['customToken']?.toString();
      if (customToken == null || customToken.isEmpty) {
        throw Exception('Token QR không hợp lệ hoặc đã hết hạn.');
      }

      final credential = await _firebaseAuth.signInWithCustomToken(customToken);
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Không thể đăng nhập bằng QR.');

      final profile = await getUserProfile(firebaseUser.uid);
      if (profile != null) return profile;

      final fallbackUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Người dùng',
        phone: firebaseUser.phoneNumber ?? '',
        authProvider: firebaseUser.phoneNumber != null ? 'phone' : 'email',
        role: 'patient',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return fallbackUser;
    } catch (e) {
      if (isMockMode && qrToken.startsWith('mock_qr_')) {
        final mockUser = _lastMockUser;
        if (mockUser != null) return mockUser;
        throw Exception('Không tìm thấy tài khoản mock để đăng nhập QR.');
      }
      throw Exception('Đăng nhập QR thất bại: ${e.toString()}');
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
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
    try {
      await _secureStorage.write(key: _biometricCredentialKey, value: payload);
    } catch (e) {
      debugPrint('Save biometric error: $e');
    }
  }

  Future<void> clearBiometricCredential() async {
    try {
      await _secureStorage.delete(key: _biometricCredentialKey);
    } catch (e) {
      debugPrint('Clear biometric error: $e');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final raw = await _secureStorage.read(key: _biometricCredentialKey);
      return raw != null && raw.isNotEmpty;
    } catch (e) {
      debugPrint('Check biometric error: $e');
      return false;
    }
  }

  Future<UserModel> loginWithBiometrics() async {
    final available = await isBiometricAvailable();
    if (!available) throw Exception('Thiết bị chưa hỗ trợ sinh trắc học.');

    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Xác thực để đăng nhập ICare',
      biometricOnly: true,
    );
    if (!didAuthenticate) throw Exception('Xác thực khuôn mặt/vân tay thất bại.');

    final raw = await _secureStorage.read(key: _biometricCredentialKey);
    if (raw == null || raw.isEmpty) {
      throw Exception('Bạn chưa bật đăng nhập bằng sinh trắc học.');
    }
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final identifier = data['identifier']?.toString() ?? '';
    final password = data['password']?.toString() ?? '';
    final requiredRole = data['requiredRole']?.toString();
    if (identifier.isEmpty || password.isEmpty) {
      throw Exception('Dữ liệu đăng nhập sinh trắc học không hợp lệ.');
    }
    return loginWithEmail(
      email: identifier,
      password: password,
      requiredRole: requiredRole?.isEmpty == true ? null : requiredRole,
    );
  }

  /// ERROR HANDLER
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'Không tìm thấy tài khoản';
      case 'wrong-password': return 'Sai mật khẩu';
      case 'invalid-credential': return 'Số điện thoại hoặc mật khẩu không đúng';
      case 'email-already-in-use': return 'Email đã được sử dụng';
      case 'weak-password': return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'invalid-email': return 'Email không hợp lệ';
      case 'too-many-requests': return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      case 'network-request-failed': return 'Lỗi kết nối mạng';
      case 'invalid-verification-code': return 'Mã OTP chưa chính xác';
      case 'invalid-verification-id': return 'Yêu cầu xác thực đã hết hạn';
      default: return 'Lỗi xác thực ($code)';
    }
  }
}

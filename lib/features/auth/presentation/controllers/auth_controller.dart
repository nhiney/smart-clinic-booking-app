import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_phone_usecase.dart';
import '../../domain/usecases/signin_with_phone_usecase.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/apps/shared/di/injection.dart';
import 'package:smart_clinic_booking/apps/shared/router/app_router.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    loginWithEmailUseCase: getIt<LoginWithEmailUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    verifyPhoneUseCase: getIt<VerifyPhoneUseCase>(),
    signInWithPhoneUseCase: getIt<SignInWithPhoneUseCase>(),
    authRepository: getIt<AuthRepository>(),
  );
});

class AuthController extends ChangeNotifier {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final SignInWithPhoneUseCase signInWithPhoneUseCase;
  final AuthRepository authRepository;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthController({
    required this.loginWithEmailUseCase,
    required this.registerUseCase,
    required this.verifyPhoneUseCase,
    required this.signInWithPhoneUseCase,
    required this.authRepository,
  }) {
    _initAuthListener();
  }

  Future<void> _restoreSession() async {
    try {
      if (await authRepository.hasSavedSession()) {
        final info = await authRepository.getLocalRegistrationInfo();
        if (info != null) {
          final phone = info['phone'] ?? '';
          final normalized = normalizePhone('+84', phone); // Defaulting to +84 for VN mock
          final virtualEmail = "$normalized@icare.patient";
          
          // If we have a saved session UID that looks like a mock user
          // we should re-hydrate the state
          final mockUid = 'MOCK_USER_$normalized';
          
          // Set router state so we don't get kicked to login
          AppRouter.mockAuthNotifier.value = true;
          
          // Load profile
          await _loadUserProfile(mockUid);
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Session restoration failed: $e');
    }
  }

  void _initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = authRepository.onAuthStateChanged.listen((user) async {
      debugPrint('[AUTH] Trạng thái Auth thay đổi: ${user?.id ?? "Thoát"}');
      if (user != null) {
        await _loadUserProfile(user.id);
      } else {
        currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final profile = await authRepository.getUserProfile(uid);
      if (profile != null) {
        currentUser = profile;
        debugPrint('[AUTH] Đã tải profile cho: ${profile.name}');
      } else {
        debugPrint('[AUTH] Không tìm thấy profile Firestore cho UID: $uid');
        // If we have auth but no profile, we might still be in registration flow
        // so we don't force log out here, but we set a minimal user
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AUTH] Lỗi tải profile: $e');
    }
  }

  bool isLoading = false;
  String? errorMessage;
  UserEntity? currentUser;
  String? verificationId;
  
  // New States
  bool isDoctorMode = false;
  int otpTimer = 0;

  Future<bool> login(String credential, String password, {String? requiredRole}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await loginWithEmailUseCase(
        credential, 
        password,
        requiredRole: requiredRole,
      );
      if (currentUser != null) {
        await authRepository.saveSession(currentUser!);
        
        // Update router if it's a mock user
        if (currentUser!.id.startsWith('MOCK_USER_')) {
          AppRouter.mockAuthNotifier.value = true;
        }
      }

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithBiometrics() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      currentUser = await authRepository.loginWithBiometrics();
      if (currentUser != null) {
        await authRepository.saveSession(currentUser!);
      }
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  }) async {
    await authRepository.saveBiometricCredential(
      identifier: identifier,
      password: password,
      requiredRole: requiredRole,
    );
  }

  Future<bool> isBiometricAvailable() async {
    return authRepository.isBiometricAvailable();
  }

  Future<bool> isBiometricEnabled() async {
    return authRepository.isBiometricEnabled();
  }

  Future<void> clearBiometricCredential() async {
    await authRepository.clearBiometricCredential();
  }

  Future<Map<String, dynamic>?> createQrLoginToken({
    bool persistent = false,
    String? targetUid,
  }) async {
    try {
      errorMessage = null;
      notifyListeners();
      return await authRepository.createQrLoginToken(
        persistent: persistent,
        targetUid: targetUid,
      );
    } catch (e) {

      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> signInWithQrToken(String qrToken) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      currentUser = await authRepository.signInWithQrToken(qrToken);
      if (currentUser != null) {
        await authRepository.saveSession(currentUser!);
      }
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    String? email,
    String? password,
    String? role,
    String? tenantId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await registerUseCase(
        name: name,
        phone: phone,
        role: role ?? 'patient',
        email: email,
        password: password,
        tenantId: tenantId,
      );
      if (currentUser != null) {
        await authRepository.saveSession(currentUser!);
      }

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveRegistrationLocally(String phone, String password) async {
    await authRepository.saveRegistrationLocally(phone, password);
  }

  /// Normalizes phone for Virtual Email generation and comparison
  static String normalizePhone(String countryCode, String phone) {
    String cleanPhone = phone.trim();
    if (countryCode == "+84" && cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    // Result: countryCodeDigits + phoneDigits
    final cleanCode = countryCode.replaceAll(RegExp(r'\D'), '');
    final cleanDigits = cleanPhone.replaceAll(RegExp(r'\D'), '');
    return '$cleanCode$cleanDigits';
  }

  Future<bool> verifyAgainstLocalRegistration(String normalizedPhone, String password) async {
    try {
      // 0. QUICK BYPASS: If this is the known debug account, allow it immediately in kDebugMode
      if (kDebugMode && (normalizedPhone == '84326583876' || normalizedPhone == '326583876') && password == 'Nhi@1234') {
        return true;
      }

      final info = await authRepository.getLocalRegistrationInfo();
      if (info == null) return true; // No local record, allow standard login
      
      final savedPhone = info['phone'] ?? '';
      final savedPassword = (info['password'] ?? '').trim();
      final inputPassword = password.trim();
      
      // Basic normalization of saved phone for comparison
      String cleanInput = normalizedPhone.replaceAll(RegExp(r'\D'), '');
      String cleanSaved = savedPhone.replaceAll(RegExp(r'\D'), '');
      
      // Compare last 9 digits to account for various prefixing formats (e.g. 09..., 849..., +849...)
      if (cleanInput.length >= 9 && cleanSaved.length >= 9) {
        final inputSuffix = cleanInput.substring(cleanInput.length - 9);
        final savedSuffix = cleanSaved.substring(cleanSaved.length - 9);
        
        if (inputSuffix == savedSuffix) {
          final isMatch = inputPassword == savedPassword;
          if (!isMatch && kDebugMode) {
            debugPrint('[AUTH] Local password mismatch for $normalizedPhone. Input: "$inputPassword", Saved: "$savedPassword"');
          }
          return isMatch;
        }
      }
      
      return true; // Match not required if it's a completely different account number
    } catch (e) {
      debugPrint('Local verification failed: $e');
      return true; // Fail safe to allowed remote login
    }
  }


  Future<void> logout() async {
    await authRepository.logout();
    currentUser = null;
    AppRouter.mockAuthNotifier.value = false;
    notifyListeners();
  }


  void updateUser(UserEntity user) {
    currentUser = user;
    notifyListeners();
  }

  Future<void> verifyPhone(String phone, {
    required void Function() onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await verifyPhoneUseCase(
        phone,
        onCodeSent: (id) {
          verificationId = id;
          isLoading = false;
          startOtpTimer();
          notifyListeners();
          onCodeSent();
        },
        onAutoVerified: () {
          isLoading = false;
          notifyListeners();
          onAutoVerified();
        },
        onError: (error) {
          errorMessage = error;
          isLoading = false;
          notifyListeners();
          onError(error);
        },
      );
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      onError(errorMessage!);
    }
  }

  void startOtpTimer() {
    otpTimer = 60;
    notifyListeners();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (otpTimer > 0) {
        otpTimer--;
        notifyListeners();
        return true;
      }
      return false;
    });
  }

  Future<bool> verifyOtp(String smsCode, {String? name}) async {
    if (verificationId == null) {
      errorMessage = "Yêu cầu xác thực đã hết hạn.";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await signInWithPhoneUseCase(
        verificationId!, 
        smsCode,
        displayName: name,
      );
      if (currentUser != null) {
        await authRepository.saveSession(currentUser!);
      }
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkPhoneRegistered(String phone) async {
    try {
      isLoading = true;
      notifyListeners();
      final isRegistered = await verifyPhoneUseCase.repository.isPhoneRegistered(phone);
      return isRegistered;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
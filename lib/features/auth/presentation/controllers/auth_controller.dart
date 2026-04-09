import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_phone_usecase.dart';
import '../../domain/usecases/signin_with_phone_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final SignInWithPhoneUseCase signInWithPhoneUseCase;
  final AuthRepository authRepository;

  AuthController({
    required this.loginWithEmailUseCase,
    required this.registerUseCase,
    required this.verifyPhoneUseCase,
    required this.signInWithPhoneUseCase,
    required this.authRepository,
  });

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

  Future<Map<String, dynamic>?> createQrLoginToken({bool persistent = false}) async {
    try {
      errorMessage = null;
      notifyListeners();
      return await authRepository.createQrLoginToken(persistent: persistent);
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

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    currentUser = null;
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
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_phone_usecase.dart';
import '../../domain/usecases/signin_with_phone_usecase.dart';
import '../../domain/usecases/create_password_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final SignInWithPhoneUseCase signInWithPhoneUseCase;
  final CreatePasswordUseCase createPasswordUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyPhoneUseCase,
    required this.signInWithPhoneUseCase,
    required this.createPasswordUseCase,
  });

  bool isLoading = false;
  String? errorMessage;
  UserEntity? currentUser;
  String? verificationId;

  Future<bool> login(String phone, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await loginUseCase(phone, password);

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
    required String password,
    String? role,
    String? hospitalId,
    String? idCardUrl,
    String? medicalCertUrl,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await registerUseCase(
        name: name,
        phone: phone,
        password: password,
        role: role ?? 'patient',
        hospitalId: hospitalId,
        idCardUrl: idCardUrl,
        medicalCertUrl: medicalCertUrl,
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

  Future<bool> createPassword(String phone, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await createPasswordUseCase(phone, password);
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
      if (isRegistered) {
        errorMessage = "Số điện thoại này đã được đăng ký. Vui lòng đăng nhập.";
      }
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
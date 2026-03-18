import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
  });

  bool isLoading = false;
  String? errorMessage;
  UserEntity? currentUser;

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

  Future<bool> register(
    String name,
    String phone,
    String password,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await registerUseCase(
        name,
        phone,
        password,
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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
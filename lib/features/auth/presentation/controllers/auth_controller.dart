import 'package:flutter/material.dart';
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

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await loginUseCase(email, password);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String name, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      await registerUseCase(name, email, password);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
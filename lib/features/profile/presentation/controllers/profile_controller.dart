import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileController({required this.repository});

  UserEntity? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile(String userId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      profile = await repository.getProfile(userId);
    } catch (e) {
      errorMessage = 'Không thể tải thông tin hồ sơ';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserEntity user) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await repository.updateProfile(user);
      profile = user;
      return true;
    } catch (e) {
      errorMessage = 'Không thể cập nhật hồ sơ';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

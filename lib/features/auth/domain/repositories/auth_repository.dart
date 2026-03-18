import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String phone, String password);
  Future<UserEntity> register(String name, String phone, String password, {String role});
  Future<void> logout();
  UserEntity? getCurrentUser();
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
}

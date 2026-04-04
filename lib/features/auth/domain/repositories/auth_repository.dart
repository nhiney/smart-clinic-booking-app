import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String phone, String password);
  Future<UserEntity> register(String name, String phone, String password, {String role});
  Future<void> logout();
  UserEntity? getCurrentUser();
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
  Future<bool> isPhoneRegistered(String phone);
  
  // Phone Auth methods
  Future<void> verifyPhone(String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  });
  Future<UserEntity> signInWithPhone(String verificationId, String smsCode, {String? displayName});
  Future<void> createPassword(String phone, String password);
}

import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getProfile(String userId);
  Future<void> updateProfile(UserEntity user);
}

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity> login(String phone, String password) async {
    return await remoteDatasource.login(
      phone: phone,
      password: password,
    );
  }

  @override
  Future<UserEntity> register(
    String name,
    String phone,
    String password, {
    String role = 'patient',
  }) async {
    return await remoteDatasource.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDatasource.logout();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = remoteDatasource.getCurrentUser();
    if (user == null) return null;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
    );
  }

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    return await remoteDatasource.getUserProfile(uid);
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await remoteDatasource.updateUserProfile(UserModel.fromEntity(user));
  }
}

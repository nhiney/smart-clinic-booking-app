import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
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

  @override
  Future<bool> isPhoneRegistered(String phone) async {
    return await remoteDatasource.isPhoneRegistered(phone);
  }

  @override
  Future<void> verifyPhone(
    String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  }) async {
    await remoteDatasource.verifyPhone(
      phone,
      onCodeSent: onCodeSent,
      onAutoVerified: onAutoVerified,
      onError: onError,
    );
  }

  @override
  Future<UserEntity> signInWithPhone(String verificationId, String smsCode, {String? displayName}) async {
    return await remoteDatasource.signInWithPhone(
      verificationId: verificationId,
      smsCode: smsCode,
      displayName: displayName,
    );
  }

  @override
  Future<void> createPassword(String phone, String password) async {
    await remoteDatasource.createPassword(phone, password);
  }
}

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
  Stream<UserEntity?> get onAuthStateChanged => remoteDatasource.onAuthStateChanged.map((user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
    );
  });

  @override
  Future<UserEntity> loginWithEmail(String email, String password, {String? requiredRole}) async {
    return await remoteDatasource.loginWithEmail(
      email: email,
      password: password,
      requiredRole: requiredRole,
    );
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String role,
    String? email,
    String? password,
    String? tenantId,
  }) async {
    return await remoteDatasource.register(
      name: name,
      phone: phone,
      role: role,
      email: email,
      password: password,
      tenantId: tenantId,
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

    // We return a skeleton entity, but mostly used to trigger profile fetch
    return UserEntity(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
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
  Future<void> saveSession(UserEntity user) async {
    await remoteDatasource.saveSession(user);
  }

  @override
  Future<bool> hasSavedSession() async {
    return await remoteDatasource.hasSavedSession();
  }

  @override
  Future<void> clearSession() async {
    await remoteDatasource.clearSession();
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
  Future<UserEntity> signInWithQrToken(String qrToken) async {
    return await remoteDatasource.signInWithQrToken(qrToken);
  }

  @override
  Future<Map<String, dynamic>> createQrLoginToken({bool persistent = false, String? targetUid}) async {
    return await remoteDatasource.createQrLoginToken(persistent: persistent, targetUid: targetUid);
  }


  @override
  Future<bool> isBiometricAvailable() async {
    return await remoteDatasource.isBiometricAvailable();
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await remoteDatasource.isBiometricEnabled();
  }

  @override
  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  }) async {
    await remoteDatasource.saveBiometricCredential(
      identifier: identifier,
      password: password,
      requiredRole: requiredRole,
    );
  }

  @override
  Future<void> clearBiometricCredential() async {
    await remoteDatasource.clearBiometricCredential();
  }

  @override
  Future<UserEntity> loginWithBiometrics() async {
    return await remoteDatasource.loginWithBiometrics();
  }
}

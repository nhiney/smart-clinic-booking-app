import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get onAuthStateChanged;

  // Doctor / Staff / Patient Login (Email/Phone + Password)
  Future<UserEntity> loginWithEmail(String email, String password, {String? requiredRole});

  // Patient Login (Phone + OTP)
  Future<void> verifyPhone(String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  });
  Future<UserEntity> signInWithPhone(String verificationId, String smsCode, {String? displayName});
  Future<UserEntity> signInWithQrToken(String qrToken);
  Future<Map<String, dynamic>> createQrLoginToken({bool persistent = false, String? targetUid});

  // Common
  Future<void> logout();
  UserEntity? getCurrentUser();
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserEntity user);
  Future<bool> isPhoneRegistered(String phone);
  Future<void> saveSession(UserEntity user);
  Future<bool> hasSavedSession();
  Future<void> clearSession();
  Future<bool> isBiometricAvailable();
  Future<bool> isBiometricEnabled();
  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  });
  Future<void> clearBiometricCredential();
  Future<UserEntity> loginWithBiometrics();

  // Local Registration Persistence (for comparison at login)
  Future<void> saveRegistrationLocally(String phone, String password);
  Future<Map<String, String>?> getLocalRegistrationInfo();

  // Registration (Primarily for initial Patient setup if needed)
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String role,
    String? email,
    String? password,
    String? tenantId,
  });
}

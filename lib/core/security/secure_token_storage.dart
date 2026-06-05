import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Dữ liệu phiên đăng nhập được lưu trong Secure Storage.
class SessionData {
  final String uid;
  final String role;
  final String email;
  final String name;
  final String? tenantId;
  final DateTime savedAt;

  const SessionData({
    required this.uid,
    required this.role,
    required this.email,
    required this.name,
    this.tenantId,
    required this.savedAt,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      uid: json['uid'] ?? '',
      role: json['role'] ?? 'patient',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      tenantId: json['tenantId'],
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role,
        'email': email,
        'name': name,
        'tenantId': tenantId,
        'savedAt': savedAt.toIso8601String(),
      };

  /// Phiên đã quá 7 ngày → hết hạn
  bool get isExpired =>
      DateTime.now().difference(savedAt).inDays > 7;
}

/// Centralized wrapper quản lý tokens và session data
/// sử dụng `flutter_secure_storage` (Keychain trên iOS, EncryptedSharedPreferences trên Android).
///
/// Tất cả dữ liệu nhạy cảm (Access Token, Refresh Token, User Session)
/// đều được mã hoá tự động bởi OS-level encryption.
///
/// ### Nguyên tắc:
/// - **Không bao giờ** lưu token/session vào SharedPreferences
/// - **Không bao giờ** log token ra console (kể cả debug)
/// - Tự động xoá khi logout
class SecureTokenStorage {
  SecureTokenStorage._();
  static final SecureTokenStorage instance = SecureTokenStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ── Storage Keys ──────────────────────────────────────────────────
  static const String _accessTokenKey = 'icare_access_token_v2';
  static const String _refreshTokenKey = 'icare_refresh_token_v2';
  static const String _tokenExpiryKey = 'icare_token_expiry_v2';
  static const String _userSessionKey = 'icare_user_session_v2';
  static const String _biometricCredKey = 'icare_biometric_cred_v2';
  static const String _registrationKey = 'icare_registration_v2';

  // ── Access Token ──────────────────────────────────────────────────

  /// Lưu Access Token (Firebase ID Token) và thời điểm hết hạn.
  Future<void> saveAccessToken(String token, {DateTime? expiresAt}) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      if (expiresAt != null) {
        await _storage.write(
          key: _tokenExpiryKey,
          value: expiresAt.toIso8601String(),
        );
      }
    } catch (e) {
      debugPrint('[SecureTokenStorage] saveAccessToken error: $e');
    }
  }

  /// Đọc Access Token. Returns `null` nếu không tồn tại.
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      debugPrint('[SecureTokenStorage] getAccessToken error: $e');
      return null;
    }
  }

  /// Kiểm tra token đã hết hạn chưa.
  Future<bool> isTokenExpired() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return true;
      final expiry = DateTime.parse(expiryStr);
      // Coi là hết hạn trước 5 phút để có buffer refresh
      return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
    } catch (e) {
      debugPrint('[SecureTokenStorage] isTokenExpired error: $e');
      return true;
    }
  }

  // ── Refresh Token ─────────────────────────────────────────────────

  /// Lưu Refresh Token (nếu backend hỗ trợ).
  /// Firebase Auth tự quản lý refresh internally, nhưng ta lưu
  /// để support custom backend trong tương lai.
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('[SecureTokenStorage] saveRefreshToken error: $e');
    }
  }

  /// Đọc Refresh Token.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('[SecureTokenStorage] getRefreshToken error: $e');
      return null;
    }
  }

  // ── User Session ──────────────────────────────────────────────────

  /// Lưu thông tin phiên đăng nhập của user.
  Future<void> saveUserSession(SessionData session) async {
    try {
      final json = jsonEncode(session.toJson());
      await _storage.write(key: _userSessionKey, value: json);
    } catch (e) {
      debugPrint('[SecureTokenStorage] saveUserSession error: $e');
    }
  }

  /// Đọc user session đã lưu. Returns `null` nếu chưa login.
  Future<SessionData?> getUserSession() async {
    try {
      final raw = await _storage.read(key: _userSessionKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SessionData.fromJson(map);
    } catch (e) {
      debugPrint('[SecureTokenStorage] getUserSession error: $e');
      return null;
    }
  }

  /// Kiểm tra có session đã lưu không.
  Future<bool> hasSavedSession() async {
    try {
      final session = await getUserSession();
      return session != null && !session.isExpired;
    } catch (_) {
      return false;
    }
  }

  // ── Biometric Credentials ─────────────────────────────────────────

  /// Lưu credentials cho đăng nhập bằng sinh trắc học.
  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  }) async {
    try {
      final payload = jsonEncode({
        'identifier': identifier,
        'password': password,
        'requiredRole': requiredRole,
      });
      await _storage.write(key: _biometricCredKey, value: payload);
    } catch (e) {
      debugPrint('[SecureTokenStorage] saveBiometricCredential error: $e');
    }
  }

  /// Đọc biometric credentials.
  Future<Map<String, dynamic>?> getBiometricCredential() async {
    try {
      final raw = await _storage.read(key: _biometricCredKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[SecureTokenStorage] getBiometricCredential error: $e');
      return null;
    }
  }

  /// Kiểm tra đã bật đăng nhập sinh trắc học chưa.
  Future<bool> isBiometricEnabled() async {
    final cred = await getBiometricCredential();
    return cred != null;
  }

  /// Xoá biometric credentials.
  Future<void> clearBiometricCredential() async {
    try {
      await _storage.delete(key: _biometricCredKey);
    } catch (e) {
      debugPrint('[SecureTokenStorage] clearBiometricCredential error: $e');
    }
  }

  // ── Registration Info ─────────────────────────────────────────────

  /// Lưu thông tin đăng ký (phone + hashed password) vào secure storage.
  Future<void> saveRegistrationInfo({
    required String phone,
    required String passwordHash,
  }) async {
    try {
      final payload = jsonEncode({
        'phone': phone,
        'passwordHash': passwordHash,
      });
      await _storage.write(key: _registrationKey, value: payload);
    } catch (e) {
      debugPrint('[SecureTokenStorage] saveRegistrationInfo error: $e');
    }
  }

  /// Đọc thông tin đăng ký đã lưu.
  Future<Map<String, String>?> getRegistrationInfo() async {
    try {
      final raw = await _storage.read(key: _registrationKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'phone': map['phone']?.toString() ?? '',
        'passwordHash': map['passwordHash']?.toString() ?? '',
      };
    } catch (e) {
      debugPrint('[SecureTokenStorage] getRegistrationInfo error: $e');
      return null;
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────

  /// Xoá tất cả tokens (khi logout).
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenExpiryKey);
    } catch (e) {
      debugPrint('[SecureTokenStorage] clearTokens error: $e');
    }
  }

  /// Xoá session (khi logout).
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _userSessionKey);
    } catch (e) {
      debugPrint('[SecureTokenStorage] clearSession error: $e');
    }
  }

  /// Xoá toàn bộ dữ liệu secure storage (full logout / reset app).
  Future<void> clearAll() async {
    try {
      await clearTokens();
      await clearSession();
      await clearBiometricCredential();
      await _storage.delete(key: _registrationKey);
      debugPrint('[SecureTokenStorage] Đã xoá toàn bộ secure storage.');
    } catch (e) {
      debugPrint('[SecureTokenStorage] clearAll error: $e');
    }
  }
}

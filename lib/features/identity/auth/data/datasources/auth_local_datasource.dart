import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'package:smart_clinic_booking/core/security/encryption_service.dart';
import 'package:smart_clinic_booking/core/security/secure_token_storage.dart';
import '../models/user_model.dart';

/// Local Datasource chịu trách nhiệm quản lý dữ liệu nhạy cảm
/// trên thiết bị di động sử dụng `flutter_secure_storage`.
///
/// ### Single Responsibility:
/// - Cache user session (encrypted)
/// - Quản lý tokens (access/refresh)
/// - Lưu biometric credentials (encrypted)
/// - Lưu thông tin đăng ký (hashed password)
///
/// ### Nguyên tắc bảo mật:
/// - Tất cả data được mã hoá bởi OS-level encryption
///   (Keychain trên iOS, EncryptedSharedPreferences trên Android)
/// - Password luôn được hash trước khi lưu
/// - Tokens tự động xoá khi logout
@lazySingleton
class AuthLocalDatasource {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage.instance;
  final EncryptionService _encryptionService = EncryptionService.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _cachedUserKey = 'icare_cached_user_v2';

  // ── User Session Cache ────────────────────────────────────────────

  /// Lưu user model vào Secure Storage sau khi login thành công.
  Future<void> cacheUserSession(UserModel user) async {
    try {
      final json = jsonEncode(user.toSecureJson());
      await _secureStorage.write(key: _cachedUserKey, value: json);

      // Đồng thời lưu SessionData vào SecureTokenStorage
      await _tokenStorage.saveUserSession(SessionData(
        uid: user.id,
        role: user.role,
        email: user.email,
        name: user.name,
        tenantId: user.tenantId,
        savedAt: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('[AuthLocalDS] cacheUserSession error: $e');
    }
  }

  /// Đọc cached user (cho offline access / session restore).
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = await _secureStorage.read(key: _cachedUserKey);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromSecureJson(map);
    } catch (e) {
      debugPrint('[AuthLocalDS] getCachedUser error: $e');
      return null;
    }
  }

  // ── Token Management ──────────────────────────────────────────────

  /// Lưu Access Token + thời hạn.
  Future<void> cacheAccessToken(String token, {DateTime? expiresAt}) async {
    await _tokenStorage.saveAccessToken(token, expiresAt: expiresAt);
  }

  /// Đọc Access Token.
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// Lưu Refresh Token.
  Future<void> cacheRefreshToken(String token) async {
    await _tokenStorage.saveRefreshToken(token);
  }

  /// Đọc Refresh Token.
  Future<String?> getRefreshToken() async {
    return await _tokenStorage.getRefreshToken();
  }

  /// Kiểm tra token hết hạn.
  Future<bool> isTokenExpired() async {
    return await _tokenStorage.isTokenExpired();
  }

  // ── Session Queries ───────────────────────────────────────────────

  /// Kiểm tra có session đã lưu và còn hạn.
  Future<bool> hasSavedSession() async {
    return await _tokenStorage.hasSavedSession();
  }

  /// Lấy session data.
  Future<SessionData?> getSessionData() async {
    return await _tokenStorage.getUserSession();
  }

  // ── Biometric ─────────────────────────────────────────────────────

  /// Lưu credentials cho sinh trắc học.
  Future<void> saveBiometricCredential({
    required String identifier,
    required String password,
    String? requiredRole,
  }) async {
    await _tokenStorage.saveBiometricCredential(
      identifier: identifier,
      password: password,
      requiredRole: requiredRole,
    );
  }

  /// Đọc biometric credentials.
  Future<Map<String, dynamic>?> getBiometricCredential() async {
    return await _tokenStorage.getBiometricCredential();
  }

  /// Kiểm tra đã bật sinh trắc học.
  Future<bool> isBiometricEnabled() async {
    return await _tokenStorage.isBiometricEnabled();
  }

  /// Xoá biometric credentials.
  Future<void> clearBiometricCredential() async {
    await _tokenStorage.clearBiometricCredential();
  }

  // ── Registration Info ─────────────────────────────────────────────

  /// Lưu thông tin đăng ký với password đã hash.
  Future<void> saveRegistrationInfo({
    required String phone,
    required String password,
  }) async {
    // Hash password trước khi lưu
    final passwordHash = _encryptionService.hashPassword(password);
    await _tokenStorage.saveRegistrationInfo(
      phone: phone,
      passwordHash: passwordHash,
    );
  }

  /// Đọc thông tin đăng ký.
  Future<Map<String, String>?> getRegistrationInfo() async {
    return await _tokenStorage.getRegistrationInfo();
  }

  /// Xác thực password đã lưu (dùng cho local login verification).
  Future<bool> verifyLocalPassword(String phone, String password) async {
    try {
      final info = await _tokenStorage.getRegistrationInfo();
      if (info == null) return true; // Không có local record → cho phép remote

      final savedPhone = info['phone'] ?? '';
      final savedHash = info['passwordHash'] ?? '';

      // So sánh phone (last 9 digits)
      final cleanInput = phone.replaceAll(RegExp(r'\D'), '');
      final cleanSaved = savedPhone.replaceAll(RegExp(r'\D'), '');

      if (cleanInput.length >= 9 && cleanSaved.length >= 9) {
        final inputSuffix = cleanInput.substring(cleanInput.length - 9);
        final savedSuffix = cleanSaved.substring(cleanSaved.length - 9);

        if (inputSuffix == savedSuffix) {
          return _encryptionService.verifyPassword(password, savedHash);
        }
      }

      return true; // Số khác → không áp dụng local verification
    } catch (e) {
      debugPrint('[AuthLocalDS] verifyLocalPassword error: $e');
      return true; // Fail-safe: cho phép login qua remote
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────

  /// Xoá toàn bộ cached data (khi logout).
  Future<void> clearAllCachedData() async {
    try {
      await _secureStorage.delete(key: _cachedUserKey);
      await _tokenStorage.clearTokens();
      await _tokenStorage.clearSession();
      debugPrint('[AuthLocalDS] ✅ Đã xoá toàn bộ cached data');
    } catch (e) {
      debugPrint('[AuthLocalDS] clearAllCachedData error: $e');
    }
  }

  /// Xoá hoàn toàn tất cả dữ liệu (reset app).
  Future<void> clearEverything() async {
    try {
      await _secureStorage.delete(key: _cachedUserKey);
      await _tokenStorage.clearAll();
      debugPrint('[AuthLocalDS] ✅ Full reset hoàn tất');
    } catch (e) {
      debugPrint('[AuthLocalDS] clearEverything error: $e');
    }
  }
}

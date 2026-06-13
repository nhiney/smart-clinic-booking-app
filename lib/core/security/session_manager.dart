import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import './secure_token_storage.dart';

/// Quản lý vòng đời phiên đăng nhập (Session Lifecycle Manager).
///
/// ### Responsibilities:
/// - Khởi tạo session sau khi login thành công
/// - Tự động refresh Firebase ID Token trước khi hết hạn
/// - Cung cấp auth headers cho HTTP requests
/// - Kiểm tra tính hợp lệ của session
/// - Terminate session khi logout
///
/// ### Token Refresh Strategy:
/// Firebase ID Token có TTL = 1 giờ. Service này thiết lập timer
/// để tự động refresh trước 5 phút khi token hết hạn.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final SecureTokenStorage _tokenStorage = SecureTokenStorage.instance;

  Timer? _refreshTimer;
  bool _isInitialized = false;

  /// Kiểm tra session manager đã được khởi tạo chưa.
  bool get isInitialized => _isInitialized;

  /// Khởi tạo session sau khi đăng nhập thành công.
  ///
  /// - Lấy ID Token từ Firebase
  /// - Lưu vào Secure Storage
  /// - Thiết lập timer tự động refresh
  Future<void> initSession(User firebaseUser) async {
    try {
      // 1. Lấy ID Token
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[SessionManager] ⚠️ Không lấy được ID Token');
        return;
      }

      // 2. Tính thời điểm hết hạn (Firebase ID Token TTL = 1 giờ)
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      // 3. Lưu token vào Secure Storage
      await _tokenStorage.saveAccessToken(idToken, expiresAt: expiresAt);

      // 4. Lưu Refresh Token (Firebase tự quản lý, ta lưu UID làm reference)
      await _tokenStorage.saveRefreshToken(firebaseUser.refreshToken ?? '');

      // 5. Thiết lập auto-refresh timer
      _scheduleTokenRefresh();

      _isInitialized = true;
      debugPrint('[SessionManager] ✅ Session khởi tạo thành công cho: ${firebaseUser.uid}');
    } catch (e) {
      debugPrint('[SessionManager] ❌ initSession error: $e');
    }
  }

  /// Refresh token thủ công (gọi khi nhận 401 từ server).
  ///
  /// Returns ID Token mới, hoặc `null` nếu thất bại.
  Future<String?> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('[SessionManager] refreshToken: no current user');
        return null;
      }

      // forceRefresh = true để bắt buộc lấy token mới
      final newToken = await user.getIdToken(true);
      if (newToken != null && newToken.isNotEmpty) {
        final expiresAt = DateTime.now().add(const Duration(hours: 1));
        await _tokenStorage.saveAccessToken(newToken, expiresAt: expiresAt);
        _scheduleTokenRefresh();
        debugPrint('[SessionManager] ✅ Token refreshed thành công');
        return newToken;
      }
    } catch (e) {
      debugPrint('[SessionManager] ❌ refreshToken error: $e');
    }
    return null;
  }

  /// Refresh token nếu sắp hết hạn (< 5 phút).
  ///
  /// Returns token hiện tại nếu còn valid, token mới nếu đã refresh.
  Future<String?> refreshTokenIfNeeded() async {
    try {
      final isExpired = await _tokenStorage.isTokenExpired();
      if (isExpired) {
        debugPrint('[SessionManager] Token sắp hết hạn, đang refresh...');
        return await refreshToken();
      }
      return await _tokenStorage.getAccessToken();
    } catch (e) {
      debugPrint('[SessionManager] refreshTokenIfNeeded error: $e');
      return null;
    }
  }

  /// Kiểm tra session hiện tại có hợp lệ không.
  ///
  /// Session hợp lệ khi:
  /// - Firebase Auth có currentUser
  /// - Secure Storage có session data chưa expired
  Future<bool> isSessionValid() async {
    try {
      // 1. Kiểm tra Firebase Auth
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 2. Kiểm tra Secure Storage session
      final hasSession = await _tokenStorage.hasSavedSession();
      if (!hasSession) return false;

      // 3. Kiểm tra token expiry
      final isExpired = await _tokenStorage.isTokenExpired();
      if (isExpired) {
        // Thử refresh trước khi kết luận session invalid
        final refreshed = await refreshToken();
        return refreshed != null;
      }

      return true;
    } catch (e) {
      debugPrint('[SessionManager] isSessionValid error: $e');
      return false;
    }
  }

  /// Lấy auth headers cho HTTP requests.
  ///
  /// ```dart
  /// final headers = await SessionManager.instance.getAuthHeaders();
  /// dio.options.headers.addAll(headers);
  /// ```
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await refreshTokenIfNeeded();
    if (token == null || token.isEmpty) {
      return {};
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Kết thúc session (logout).
  ///
  /// - Huỷ refresh timer
  /// - Xoá tokens khỏi Secure Storage
  /// - Xoá session data
  Future<void> terminateSession() async {
    try {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      _isInitialized = false;

      await _tokenStorage.clearTokens();
      await _tokenStorage.clearSession();

      debugPrint('[SessionManager] ✅ Session terminated');
    } catch (e) {
      debugPrint('[SessionManager] terminateSession error: $e');
    }
  }

  /// Thiết lập timer tự động refresh token trước 5 phút khi hết hạn.
  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();

    // Firebase ID Token TTL = 60 phút
    // Refresh trước 5 phút → timer = 55 phút
    const refreshInterval = Duration(minutes: 55);

    _refreshTimer = Timer(refreshInterval, () async {
      debugPrint('[SessionManager] ⏰ Auto-refresh token triggered');
      await refreshToken();
    });
  }

  /// Huỷ tất cả timers khi app bị dispose.
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

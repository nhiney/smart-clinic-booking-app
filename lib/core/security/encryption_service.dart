import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Service mã hoá mật khẩu sử dụng HMAC-SHA256 + random salt.
///
/// Lưu ý: Firebase Auth đã xử lý server-side password hashing (scrypt)
/// khi gọi `createUserWithEmailAndPassword`. Service này dùng để hash
/// password **trước khi lưu vào Firestore** (collection `users`),
/// đảm bảo không bao giờ lưu plaintext password.
///
/// Thuật toán: HMAC-SHA256(password, salt)
/// Output format: "salt:hash" (base64)
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  static const int _saltLength = 32;
  static const int _iterationCount = 10000;

  final Random _secureRandom = Random.secure();

  /// Sinh chuỗi salt ngẫu nhiên (32 bytes → base64).
  String _generateSalt() {
    final saltBytes = List<int>.generate(
      _saltLength,
      (_) => _secureRandom.nextInt(256),
    );
    return base64Url.encode(saltBytes);
  }

  /// Hash password với salt mới.
  ///
  /// Returns chuỗi có format: `salt:hash` (cả hai đều base64).
  /// Chuỗi này có thể lưu trực tiếp vào Firestore field `password_hash`.
  String hashPassword(String plaintext) {
    if (plaintext.isEmpty) {
      throw ArgumentError('Password không được để trống.');
    }

    final salt = _generateSalt();
    final hash = _computeHash(plaintext, salt);
    return '$salt:$hash';
  }

  /// Xác thực password bằng cách so sánh hash.
  ///
  /// [plaintext] — mật khẩu người dùng nhập vào.
  /// [storedHash] — chuỗi `salt:hash` đã lưu trong Firestore.
  ///
  /// Returns `true` nếu mật khẩu khớp.
  bool verifyPassword(String plaintext, String storedHash) {
    try {
      if (plaintext.isEmpty || storedHash.isEmpty) return false;

      // Nếu storedHash không chứa ":" → đây là plaintext cũ (chưa hash)
      // So sánh trực tiếp để backward compatible
      if (!storedHash.contains(':')) {
        debugPrint('[EncryptionService] ⚠️ Phát hiện password plaintext cũ, '
            'so sánh trực tiếp. Cần migrate.');
        return plaintext == storedHash;
      }

      final parts = storedHash.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final expectedHash = parts[1];
      final actualHash = _computeHash(plaintext, salt);

      return expectedHash == actualHash;
    } catch (e) {
      debugPrint('[EncryptionService] verifyPassword error: $e');
      return false;
    }
  }

  /// Kiểm tra một password đã được hash chưa.
  ///
  /// Heuristic: chuỗi đã hash có format `base64salt:base64hash`
  /// và tổng chiều dài > 60 ký tự.
  bool isHashed(String value) {
    if (value.isEmpty) return false;
    if (!value.contains(':')) return false;
    final parts = value.split(':');
    if (parts.length != 2) return false;
    // Salt base64 ~44 chars, Hash base64 ~44 chars
    return parts[0].length >= 20 && parts[1].length >= 20;
  }

  /// HMAC-SHA256 lặp nhiều lần (key stretching đơn giản).
  ///
  /// Iterate [_iterationCount] lần để tăng chi phí brute-force.
  String _computeHash(String plaintext, String salt) {
    final key = utf8.encode(salt);
    Uint8List data = Uint8List.fromList(utf8.encode(plaintext));

    for (int i = 0; i < _iterationCount; i++) {
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(data);
      data = Uint8List.fromList(digest.bytes);
    }

    return base64Url.encode(data);
  }

  /// Sinh secure random token (dùng cho session token, CSRF, etc.)
  ///
  /// [length] — số bytes (default: 32 → 256 bits)
  String generateSecureToken([int length = 32]) {
    final bytes = List<int>.generate(
      length,
      (_) => _secureRandom.nextInt(256),
    );
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Sinh OTP số (6 chữ số).
  String generateOtp([int digits = 6]) {
    final max = pow(10, digits).toInt();
    final otp = _secureRandom.nextInt(max);
    return otp.toString().padLeft(digits, '0');
  }
}

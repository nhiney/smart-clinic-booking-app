import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates and verifies HMAC-SHA-256 signed check-in tokens.
///
/// Token format (two dot-separated parts):
///   base64url(json_payload) + "." + hmac_sha256_hex(base64url_payload)
///
/// Payload fields:
///   bid  – booking / appointment ID
///   uid  – patient user ID
///   iat  – issued-at  (ms since epoch)
///   nbf  – not-before (ms since epoch) = appointmentTime - 1 h
///   exp  – expires-at (ms since epoch) = appointmentTime + 30 min
class QrTokenService {
  static const _secret = 'icare_checkin_hmac_2024';

  /// Generate a signed token for [bookingId] / [userId].
  /// [appointmentTime] is used to set the valid window.
  static ({String token, DateTime nbf, DateTime exp}) generate({
    required String bookingId,
    required String userId,
    required DateTime appointmentTime,
  }) {
    final now = DateTime.now();
    final nbf = appointmentTime.subtract(const Duration(hours: 1));
    final exp = appointmentTime.add(const Duration(minutes: 30));

    final payload = {
      'bid': bookingId,
      'uid': userId,
      'iat': now.millisecondsSinceEpoch,
      'nbf': nbf.millisecondsSinceEpoch,
      'exp': exp.millisecondsSinceEpoch,
    };

    final encodedPayload = base64Url
        .encode(utf8.encode(jsonEncode(payload)))
        .replaceAll('=', '');

    final sig = _sign(encodedPayload);
    return (token: '$encodedPayload.$sig', nbf: nbf, exp: exp);
  }

  /// Verify [token] and return its payload.
  /// Throws [QrTokenException] on format error, bad signature, or expiry.
  static Map<String, dynamic> verify(String token) {
    final parts = token.split('.');
    if (parts.length != 2) throw const QrTokenException('invalid_format');

    final encodedPayload = parts[0];
    final receivedSig = parts[1];

    if (_sign(encodedPayload) != receivedSig) {
      throw const QrTokenException('invalid_signature');
    }

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(encodedPayload))),
      ) as Map<String, dynamic>;
    } catch (_) {
      throw const QrTokenException('invalid_format');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > (payload['exp'] as int)) throw const QrTokenException('expired');
    if (now < (payload['nbf'] as int)) throw const QrTokenException('not_yet_valid');

    return payload;
  }

  static String _sign(String data) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    return hmac.convert(utf8.encode(data)).toString();
  }
}

class QrTokenException implements Exception {
  final String code;
  const QrTokenException(this.code);

  String get message {
    switch (code) {
      case 'invalid_format':
        return 'Mã QR không hợp lệ';
      case 'invalid_signature':
        return 'Mã QR đã bị giả mạo';
      case 'expired':
        return 'Mã QR đã hết hạn';
      case 'not_yet_valid':
        return 'Mã QR chưa đến giờ có hiệu lực';
      default:
        return 'Lỗi mã QR: $code';
    }
  }

  @override
  String toString() => 'QrTokenException($code): $message';
}

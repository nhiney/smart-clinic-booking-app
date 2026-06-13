import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../entities/check_in_entity.dart';

/// Pure, deterministic builder for check-in QR tokens and their validity window.
///
/// Centralizes the business rule so it can be used both synchronously on the
/// client (to render the QR immediately) and on the data layer (to persist the
/// same token for the clinic to verify) without a network round-trip.
class CheckInTokenFactory {
  CheckInTokenFactory._();

  static const String hmacSecret = 'smart_clinic_secret_key';

  /// Validity window per spec: the QR opens 2 hours before the appointment and
  /// closes 5 minutes after the scheduled time. Walk-ins (no [appointmentTime])
  /// get a token valid from issuance until 2 hours later.
  static CheckInEntity build({
    required String patientId,
    required String appointmentId,
    DateTime? appointmentTime,
    DateTime? now,
  }) {
    final issuedAt = now ?? DateTime.now();
    final validFrom =
        appointmentTime?.subtract(const Duration(hours: 2)) ?? issuedAt;
    final expiresAt = appointmentTime?.add(const Duration(minutes: 5)) ??
        issuedAt.add(const Duration(hours: 2));

    final payload = {
      'patientId': patientId,
      'appointmentId': appointmentId,
      'validFrom': validFrom.millisecondsSinceEpoch,
      'exp': expiresAt.millisecondsSinceEpoch,
      'iat': issuedAt.millisecondsSinceEpoch,
    };

    final jsonPayload = jsonEncode(payload);
    final hmac = Hmac(sha256, utf8.encode(hmacSecret));
    final signature = hmac.convert(utf8.encode(jsonPayload)).toString();
    final token = base64Encode(utf8.encode('$jsonPayload.$signature'));

    return CheckInEntity(
      appointmentId: appointmentId,
      patientId: patientId,
      token: token,
      validFrom: validFrom,
      expiresAt: expiresAt,
    );
  }
}

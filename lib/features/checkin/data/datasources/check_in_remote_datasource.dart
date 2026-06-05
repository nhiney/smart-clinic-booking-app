import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/services/check_in_token_factory.dart';

const _hmacSecret = CheckInTokenFactory.hmacSecret;

class CheckInRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CheckInEntity> generateToken({
    required String patientId,
    required String appointmentId,
    DateTime? appointmentTime,
  }) async {
    final entity = CheckInTokenFactory.build(
      patientId: patientId,
      appointmentId: appointmentId,
      appointmentTime: appointmentTime,
    );

    // Persist token on the appointment document so the clinic can verify it.
    await _firestore.collection('appointments').doc(appointmentId).update({
      'checkInToken': entity.token,
      'checkInValidFrom': Timestamp.fromDate(entity.validFrom),
      'checkInExpiresAt': Timestamp.fromDate(entity.expiresAt),
    });

    return entity;
  }

  Future<CheckInEntity> verifyAndProcess(String qrPayload) async {
    final decoded = utf8.decode(base64Decode(qrPayload));
    final lastDot = decoded.lastIndexOf('.');
    if (lastDot == -1) throw const FormatException('Invalid QR format');

    final jsonPart = decoded.substring(0, lastDot);
    final receivedSig = decoded.substring(lastDot + 1);

    final hmac = Hmac(sha256, utf8.encode(_hmacSecret));
    final expectedSig = hmac.convert(utf8.encode(jsonPart)).toString();
    if (receivedSig != expectedSig) {
      throw StateError('Chữ ký QR không hợp lệ');
    }

    final data = jsonDecode(jsonPart) as Map<String, dynamic>;
    final appointmentId = data['appointmentId'] as String;
    final patientId = data['patientId'] as String;
    final validFrom = DateTime.fromMillisecondsSinceEpoch(data['validFrom'] as int);
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(data['exp'] as int);

    final now = DateTime.now();
    if (now.isBefore(validFrom) || now.isAfter(expiresAt)) {
      throw StateError('Mã QR đã hết hiệu lực');
    }

    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'checkedIn',
      'checkedInAt': FieldValue.serverTimestamp(),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });

    return CheckInEntity(
      appointmentId: appointmentId,
      patientId: patientId,
      token: qrPayload,
      validFrom: validFrom,
      expiresAt: expiresAt,
      checkedInAt: now,
    );
  }
}

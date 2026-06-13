import '../entities/check_in_entity.dart';

abstract class CheckInRepository {
  /// Generates a signed check-in token and persists it to the backend.
  Future<CheckInEntity> generateToken({
    required String patientId,
    required String appointmentId,
    DateTime? appointmentTime,
  });

  /// Decodes and validates a raw QR payload, then marks the appointment as checked-in.
  /// Returns the processed [CheckInEntity] on success.
  Future<CheckInEntity> verifyAndProcess(String qrPayload);
}

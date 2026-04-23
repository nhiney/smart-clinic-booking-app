import '../entities/check_in_result_entity.dart';

abstract class QrKioskRepository {
  /// Validates the appointment in Firestore and updates its status to 'checked_in'.
  /// Uses a transaction to ensure atomicity.
  Future<CheckInResultEntity> processCheckIn(String appointmentId);
}

import '../entities/check_in_result_entity.dart';
import '../repositories/qr_kiosk_repository.dart';
import '../exceptions/qr_checkin_exceptions.dart';

class ProcessCheckInUseCase {
  final QrKioskRepository repository;

  ProcessCheckInUseCase(this.repository);

  Future<CheckInResultEntity> execute(String qrData) async {
    // 1. Basic validation of QR Data
    if (qrData.isEmpty) {
      throw InvalidQRCodeException();
    }

    // Assume qrData is the Appointment ID for now
    final appointmentId = qrData;

    // 2. Call repository to get basic data for time validation
    // In a real flow, we might fetch first, but to keep Step 2's Transaction logic 
    // as the primary source of truth, we will let the repository handle the check.
    // However, the prompt asks to "incorporate the time constraint: cannot check-in more than 60 mins early".
    
    final result = await repository.processCheckIn(appointmentId);

    // 3. Post-fetch Time validation (Business Logic)
    final now = DateTime.now();
    final difference = result.scheduledTime.difference(now).inMinutes;

    if (difference > 60) {
      throw TooEarlyException(difference);
    }

    return result;
  }
}

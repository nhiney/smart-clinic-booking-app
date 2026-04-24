import 'package:smart_clinic_booking/core/services/qr_token_service.dart';
import '../entities/check_in_result_entity.dart';
import '../repositories/qr_checkin_repository.dart';
import '../exceptions/qr_checkin_exceptions.dart';

class ProcessCheckInUseCase {
  final IQRCheckInRepository repository;

  ProcessCheckInUseCase(this.repository);

  Future<CheckInResultEntity> call(String qrData) async {
    if (qrData.isEmpty) throw InvalidQRCodeException();

    // 1. Verify HMAC signature and expiry window.
    final Map<String, dynamic> payload;
    try {
      payload = QrTokenService.verify(qrData);
    } on QrTokenException catch (e) {
      switch (e.code) {
        case 'expired':
          throw ExpiredQRCodeException();
        case 'not_yet_valid':
          throw TooEarlyException(0);
        default:
          throw InvalidQRCodeException();
      }
    }

    // 2. Extract booking ID and process check-in via Firestore.
    final bookingId = payload['bid']?.toString() ?? '';
    if (bookingId.isEmpty) throw InvalidQRCodeException();

    final result = await repository.processCheckIn(bookingId);

    // 3. Post-fetch time guard (belt-and-suspenders for the kiosk).
    final now = DateTime.now();
    final difference = result.scheduledTime.difference(now).inMinutes;
    if (difference > 60) throw TooEarlyException(difference);

    return result;
  }
}

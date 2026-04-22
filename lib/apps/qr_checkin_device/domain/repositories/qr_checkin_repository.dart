import '../entities/check_in_result_entity.dart';

abstract class IQRCheckInRepository {
  /// Xác thực thiết bị Kiosk Scanner
  Future<void> authenticateScanner();

  /// Xử lý check-in bằng ID lịch hẹn
  /// Thực hiện Transaction để đảm bảo tính nhất quán
  Future<CheckInResultEntity> processCheckIn(String bookingId);
}

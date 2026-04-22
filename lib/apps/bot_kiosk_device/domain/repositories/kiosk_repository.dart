import '../entities/slot_entity.dart';

abstract class IKioskRepository {
  /// Xác thực thiết bị Kiosk bằng tài khoản chuyên biệt
  Future<void> authenticateKiosk(String deviceId, String secret);

  /// Lấy danh sách các khung giờ còn trống của bác sĩ theo ngày
  Future<List<SlotEntity>> getAvailableSlots(String doctorId, DateTime date);

  /// Giữ chỗ (Reserve) một slot khám bằng Transaction
  Future<void> reserveSlot(String slotId, String patientId);
}

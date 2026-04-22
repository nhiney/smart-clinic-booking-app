import '../entities/slot_entity.dart';

abstract class IKioskRepository {
  /// Xác thực thiết bị Kiosk bằng tài khoản chuyên biệt
  Future<void> authenticateKiosk(String email, String password);

  /// Lấy danh sách các khung giờ còn trống của bác sĩ
  Future<List<SlotEntity>> getAvailableSlots(String doctorId);

  /// Giữ chỗ (Reserve) một slot khám bằng Transaction
  /// Ném ra [SlotAlreadyBookedException] nếu thất bại
  Future<void> reserveSlot({
    required String doctorId,
    required String slotId,
    required String patientId,
  });
}

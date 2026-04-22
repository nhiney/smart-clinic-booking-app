import '../entities/check_in_result_entity.dart';
import '../repositories/qr_checkin_repository.dart';

class ProcessCheckInUseCase {
  final IQRCheckInRepository repository;

  ProcessCheckInUseCase(this.repository);

  /// Logic:
  /// 1. Giải mã JSON (đã xử lý ở tầng Presentation hoặc Datasource)
  /// 2. Gọi repository thực hiện Transaction
  /// 3. Xử lý các ngoại lệ nghiệp vụ (TooEarly, AlreadyCheckedIn, v.v.)
  Future<CheckInResultEntity> call(String bookingId) async {
    // Note: Business constraints (TooEarly, AlreadyCheckedIn) 
    // are implemented inside the Firestore Transaction in the Data Layer 
    // to ensure atomicity.
    return await repository.processCheckIn(bookingId);
  }
}

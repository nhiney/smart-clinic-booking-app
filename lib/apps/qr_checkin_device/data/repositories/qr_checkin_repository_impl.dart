import 'package:smart_clinic_booking/apps/qr_checkin_device/data/datasources/qr_checkin_remote_datasource.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/entities/check_in_result_entity.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/repositories/qr_checkin_repository.dart';

class QRCheckInRepositoryImpl implements IQRCheckInRepository {
  final IQRCheckInRemoteDataSource remoteDataSource;

  QRCheckInRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> authenticateScanner() async {
    // Logic xác thực thiết bị (có thể mở rộng thêm)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<CheckInResultEntity> processCheckIn(String bookingId) async {
    return await remoteDataSource.processCheckIn(bookingId);
  }
}

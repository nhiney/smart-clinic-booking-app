import 'package:smart_clinic_booking/apps/bot_kiosk_device/data/datasources/kiosk_remote_datasource.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/entities/slot_entity.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/repositories/kiosk_repository.dart';

class KioskRepositoryImpl implements IKioskRepository {
  final IKioskRemoteDataSource remoteDataSource;

  KioskRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> authenticateKiosk(String deviceId, String secret) async {
    // Logic xác thực Kiosk (Mocking for now as per Step 1 requirement)
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> reserveSlot(String slotId, String patientId) async {
    return await remoteDataSource.reserveSlot(slotId, patientId);
  }

  @override
  Future<List<SlotEntity>> getAvailableSlots(String doctorId, DateTime date) async {
    return await remoteDataSource.getAvailableSlots(doctorId, date);
  }
}

import '../../domain/entities/check_in_result_entity.dart';
import '../../domain/repositories/qr_kiosk_repository.dart';
import '../datasources/qr_kiosk_remote_datasource.dart';

class QrKioskRepositoryImpl implements QrKioskRepository {
  final QrKioskRemoteDataSource remoteDataSource;

  QrKioskRepositoryImpl(this.remoteDataSource);

  @override
  Future<CheckInResultEntity> processCheckIn(String appointmentId) async {
    final model = await remoteDataSource.runCheckInTransaction(appointmentId);
    return model.toEntity();
  }
}

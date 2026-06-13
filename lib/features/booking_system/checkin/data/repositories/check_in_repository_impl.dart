import '../../domain/entities/check_in_entity.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../datasources/check_in_remote_datasource.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDatasource _datasource;

  CheckInRepositoryImpl(this._datasource);

  @override
  Future<CheckInEntity> generateToken({
    required String patientId,
    required String appointmentId,
    DateTime? appointmentTime,
  }) =>
      _datasource.generateToken(
        patientId: patientId,
        appointmentId: appointmentId,
        appointmentTime: appointmentTime,
      );

  @override
  Future<CheckInEntity> verifyAndProcess(String qrPayload) =>
      _datasource.verifyAndProcess(qrPayload);
}

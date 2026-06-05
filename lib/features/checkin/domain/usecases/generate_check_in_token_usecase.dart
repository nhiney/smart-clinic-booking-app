import '../entities/check_in_entity.dart';
import '../repositories/check_in_repository.dart';

class GenerateCheckInTokenUseCase {
  final CheckInRepository _repository;

  GenerateCheckInTokenUseCase(this._repository);

  Future<CheckInEntity> call({
    required String patientId,
    required String appointmentId,
    DateTime? appointmentTime,
  }) =>
      _repository.generateToken(
        patientId: patientId,
        appointmentId: appointmentId,
        appointmentTime: appointmentTime,
      );
}

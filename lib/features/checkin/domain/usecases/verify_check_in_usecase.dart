import '../entities/check_in_entity.dart';
import '../repositories/check_in_repository.dart';

class VerifyCheckInUseCase {
  final CheckInRepository _repository;

  VerifyCheckInUseCase(this._repository);

  Future<CheckInEntity> call(String qrPayload) =>
      _repository.verifyAndProcess(qrPayload);
}

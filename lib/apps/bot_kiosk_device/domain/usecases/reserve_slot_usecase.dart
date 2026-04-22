import '../repositories/kiosk_repository.dart';

class ReserveSlotUseCase {
  final IKioskRepository repository;

  ReserveSlotUseCase(this.repository);

  Future<void> call(String slotId, String patientId) async {
    return await repository.reserveSlot(slotId, patientId);
  }
}

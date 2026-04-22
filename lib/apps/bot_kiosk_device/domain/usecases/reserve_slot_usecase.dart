import '../repositories/kiosk_repository.dart';

class ReserveSlotUseCase {
  final IKioskRepository repository;

  ReserveSlotUseCase(this.repository);

  Future<void> call({
    required String doctorId,
    required String slotId,
    required String patientId,
  }) async {
    return await repository.reserveSlot(
      doctorId: doctorId,
      slotId: slotId,
      patientId: patientId,
    );
  }
}

import '../entities/doctor_schedule_slot.dart';
import '../repositories/doctor_schedule_repository.dart';

class UpdateSlotStatusUseCase {
  final DoctorScheduleRepository _repository;

  UpdateSlotStatusUseCase(this._repository);

  Future<void> call(String appointmentId, ScheduleSlotStatus newStatus) =>
      _repository.updateSlotStatus(appointmentId, newStatus);
}

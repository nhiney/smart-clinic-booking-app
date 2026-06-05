import '../entities/doctor_schedule_slot.dart';
import '../repositories/doctor_schedule_repository.dart';

class GetDoctorDayScheduleUseCase {
  final DoctorScheduleRepository _repository;

  GetDoctorDayScheduleUseCase(this._repository);

  Future<List<DoctorScheduleSlot>> call(String doctorId, DateTime date) =>
      _repository.getScheduleForDay(doctorId, date);
}

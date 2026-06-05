import '../entities/doctor_schedule_slot.dart';

abstract class DoctorScheduleRepository {
  Future<List<DoctorScheduleSlot>> getScheduleForDay(String doctorId, DateTime date);
  Future<void> updateSlotStatus(String appointmentId, ScheduleSlotStatus newStatus);
}

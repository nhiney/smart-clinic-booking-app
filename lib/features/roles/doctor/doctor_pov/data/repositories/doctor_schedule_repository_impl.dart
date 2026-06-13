import '../../domain/entities/doctor_schedule_slot.dart';
import '../../domain/repositories/doctor_schedule_repository.dart';
import '../datasources/doctor_schedule_remote_datasource.dart';

class DoctorScheduleRepositoryImpl implements DoctorScheduleRepository {
  final DoctorScheduleRemoteDatasource _datasource;

  DoctorScheduleRepositoryImpl(this._datasource);

  @override
  Future<List<DoctorScheduleSlot>> getScheduleForDay(
          String doctorId, DateTime date) =>
      _datasource.getScheduleForDay(doctorId, date);

  @override
  Future<void> updateSlotStatus(
          String appointmentId, ScheduleSlotStatus newStatus) =>
      _datasource.updateSlotStatus(appointmentId, newStatus);
}

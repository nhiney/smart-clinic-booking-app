import '../../domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> getAppointmentsByPatient(String patientId);
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment);
  Future<void> updateAppointmentStatus(String id, String status);
  Future<void> cancelAppointment(String id);
  Future<void> rescheduleAppointment(
      String id, DateTime newDate, String newTime);
  Future<bool> lockSlot(String doctorId, DateTime date, String time);
}

import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<AppointmentEntity> call(AppointmentEntity appointment) async {
    if (appointment.patientId.trim().isEmpty) {
      throw ArgumentError('patientId is required');
    }
    if (appointment.doctorId.trim().isEmpty) {
      throw ArgumentError('doctorId is required');
    }
    if (!appointment.dateTime.isAfter(DateTime.now())) {
      throw ArgumentError('appointment dateTime must be in the future');
    }
    return await repository.createAppointment(appointment);
  }
}

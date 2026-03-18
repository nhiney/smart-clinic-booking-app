import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<AppointmentEntity> call(AppointmentEntity appointment) async {
    return await repository.createAppointment(appointment);
  }
}

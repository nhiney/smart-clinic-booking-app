import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  Future<List<AppointmentEntity>> call(String patientId) async {
    return await repository.getAppointmentsByPatient(patientId);
  }
}

import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource remoteDatasource;

  AppointmentRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<AppointmentEntity>> getAppointmentsByPatient(
      String patientId) async {
    return await remoteDatasource.getAppointmentsByPatient(patientId);
  }

  @override
  Future<AppointmentEntity> createAppointment(
      AppointmentEntity appointment) async {
    final model = AppointmentModel(
      id: '',
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      dateTime: appointment.dateTime,
      status: appointment.normalizedStatus,
      notes: appointment.notes,
      createdAt: DateTime.now(),
      queueNumber: appointment.queueNumber,
      estimatedWaitTimeMinutes: appointment.estimatedWaitTimeMinutes,
      checkInToken: appointment.checkInToken,
      paymentStatus: appointment.paymentStatus,
      priorityLevel: appointment.priorityLevel,
      statusUpdatedAt: DateTime.now(),
      checkedInAt: appointment.checkedInAt,
      completedAt: appointment.completedAt,
    );
    return await remoteDatasource.createAppointment(model);
  }

  @override
  Future<void> updateAppointmentStatus(String id, String status) async {
    await remoteDatasource.updateAppointmentStatus(id, status);
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await remoteDatasource.cancelAppointment(id);
  }

  @override
  Future<void> rescheduleAppointment(
      String id, DateTime newDate, String newTime) async {
    await remoteDatasource.rescheduleAppointment(id, newDate);
  }

  @override
  Future<bool> lockSlot(String doctorId, DateTime date, String time) async {
    return await remoteDatasource.lockSlot(doctorId, date, '');
  }
}

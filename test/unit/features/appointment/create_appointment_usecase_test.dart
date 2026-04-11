import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/features/appointment/domain/entities/appointment_entity.dart';
import 'package:smart_clinic_booking/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:smart_clinic_booking/features/appointment/domain/usecases/create_appointment_usecase.dart';

class _FakeAppointmentRepository implements AppointmentRepository {
  AppointmentEntity? createdAppointment;

  @override
  Future<void> cancelAppointment(String id) async {}

  @override
  Future<AppointmentEntity> createAppointment(
      AppointmentEntity appointment) async {
    createdAppointment = appointment;
    return appointment;
  }

  @override
  Future<List<AppointmentEntity>> getAppointmentsByPatient(
      String patientId) async {
    return [];
  }

  @override
  Future<bool> lockSlot(String doctorId, DateTime date, String time) async {
    return true;
  }

  @override
  Future<void> rescheduleAppointment(
      String id, DateTime newDate, String newTime) async {}

  @override
  Future<void> updateAppointmentStatus(String id, String status) async {}

  @override
  Future<List<AppointmentEntity>> getAppointmentsByDoctor(String doctorId) {
    // TODO: implement getAppointmentsByDoctor
    throw UnimplementedError();
  }
}

void main() {
  group('CreateAppointmentUseCase', () {
    test('throws when appointment time is not in the future', () async {
      final repository = _FakeAppointmentRepository();
      final useCase = CreateAppointmentUseCase(repository);

      final appointment = AppointmentEntity(
        id: '1',
        patientId: 'patient-1',
        doctorId: 'doctor-1',
        dateTime: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(() => useCase(appointment), throwsArgumentError);
    });

    test('creates appointment when input is valid', () async {
      final repository = _FakeAppointmentRepository();
      final useCase = CreateAppointmentUseCase(repository);

      final appointment = AppointmentEntity(
        id: '1',
        patientId: 'patient-1',
        doctorId: 'doctor-1',
        dateTime: DateTime.now().add(const Duration(days: 1)),
      );

      final result = await useCase(appointment);

      expect(result.patientId, 'patient-1');
      expect(repository.createdAppointment, isNotNull);
    });
  });
}

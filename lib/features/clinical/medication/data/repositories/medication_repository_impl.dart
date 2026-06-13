import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_intake.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDatasource remoteDatasource;

  MedicationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MedicationEntity>> getMedicationsByPatient(String patientId) {
    return remoteDatasource.getMedicationsByPatient(patientId);
  }

  @override
  Future<MedicationEntity> addMedication(MedicationModel medication) {
    return remoteDatasource.addMedication(medication);
  }

  @override
  Future<void> deleteMedication(String id) {
    return remoteDatasource.deleteMedication(id);
  }

  @override
  Future<void> toggleMedication(String id, bool isActive) {
    return remoteDatasource.toggleMedication(id, isActive);
  }

  @override
  Future<MedicationIntake> recordIntake({
    required String medicationId,
    required String patientId,
    required DateTime scheduledAt,
    required bool wasTaken,
    String? note,
  }) {
    return remoteDatasource.recordIntake(
      medicationId: medicationId,
      patientId: patientId,
      scheduledAt: scheduledAt,
      wasTaken: wasTaken,
      note: note,
    );
  }

  @override
  Future<List<MedicationIntake>> getIntakes({
    required String medicationId,
    required DateTime from,
    required DateTime to,
  }) {
    return remoteDatasource.getIntakes(medicationId: medicationId, from: from, to: to);
  }

  @override
  Future<double> getAdherenceRate(String medicationId, {int days = 30}) {
    return remoteDatasource.getAdherenceRate(medicationId, days: days);
  }
}

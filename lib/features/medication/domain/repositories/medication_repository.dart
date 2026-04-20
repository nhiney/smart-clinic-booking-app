import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_intake.dart';
import '../../data/models/medication_model.dart';

abstract class MedicationRepository {
  Future<List<MedicationEntity>> getMedicationsByPatient(String patientId);
  Future<MedicationEntity> addMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> toggleMedication(String id, bool isActive);

  // Intake tracking
  Future<MedicationIntake> recordIntake({
    required String medicationId,
    required String patientId,
    required DateTime scheduledAt,
    required bool wasTaken,
    String? note,
  });
  Future<List<MedicationIntake>> getIntakes({
    required String medicationId,
    required DateTime from,
    required DateTime to,
  });
  Future<double> getAdherenceRate(String medicationId, {int days = 30});
}

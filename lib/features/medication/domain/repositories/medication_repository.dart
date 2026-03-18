import '../../domain/entities/medication_entity.dart';
import '../../data/models/medication_model.dart';

abstract class MedicationRepository {
  Future<List<MedicationEntity>> getMedicationsByPatient(String patientId);
  Future<MedicationEntity> addMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<void> toggleMedication(String id, bool isActive);
}

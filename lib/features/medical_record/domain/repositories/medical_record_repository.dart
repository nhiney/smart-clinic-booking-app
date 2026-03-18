import '../../domain/entities/medical_record_entity.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalRecordEntity>> getRecordsByPatient(String patientId);
  Future<MedicalRecordEntity?> getRecordById(String id);
}

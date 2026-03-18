import '../entities/medical_record_entity.dart';
import '../repositories/medical_record_repository.dart';

class GetMedicalRecordsUseCase {
  final MedicalRecordRepository repository;

  GetMedicalRecordsUseCase(this.repository);

  Future<List<MedicalRecordEntity>> call(String patientId) async {
    return await repository.getRecordsByPatient(patientId);
  }
}

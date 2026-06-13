import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class GetMedicationsUseCase {
  final MedicationRepository repository;

  GetMedicationsUseCase(this.repository);

  Future<List<MedicationEntity>> call(String patientId) async {
    return await repository.getMedicationsByPatient(patientId);
  }
}

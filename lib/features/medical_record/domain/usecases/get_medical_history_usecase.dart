import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/encounter_fhir.dart';
import '../repositories/medical_record_repository.dart';

class GetMedicalHistoryUseCase {
  final MedicalRecordRepository repository;

  GetMedicalHistoryUseCase(this.repository);

  Future<Either<Failure, List<EncounterFhir>>> execute(String patientId) async {
    return await repository.getMedicalHistory(patientId);
  }
}

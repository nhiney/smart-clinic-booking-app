import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/medical_record_entity.dart';
import '../entities/encounter_fhir.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalRecordEntity>> getMedicalRecords(String userId);
  Future<void> addMedicalRecord(MedicalRecordEntity record);
  Future<Either<Failure, List<EncounterFhir>>> getMedicalHistory(String patientId);
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/admission_entity.dart';

abstract class AdmissionRepository {
  Future<Either<Failure, List<AdmissionEntity>>> getAdmissionsByPatient(String patientId);
  Future<Either<Failure, String>> requestAdmission(AdmissionEntity admission);
  Future<Either<Failure, void>> updateAdmissionStatus(String id, String status);
}

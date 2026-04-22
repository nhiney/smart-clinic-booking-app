import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/admission_entity.dart';

abstract class AdmissionRepository {
  Future<Either<Failure, List<AdmissionEntity>>> getAdmissionsByPatient(String patientId);
  Stream<List<AdmissionEntity>> watchAdmissionsByPatient(String patientId);
  Stream<AdmissionEntity?> watchAdmission(String admissionId);
  Future<Either<Failure, String>> requestAdmission(AdmissionEntity admission);
  Future<Either<Failure, void>> updateAdmissionStatus(String id, String status, {Map<String, dynamic>? extra});
  Future<Either<Failure, String>> uploadDocument(String admissionId, String patientId, File file, String fileName);
  Future<Either<Failure, void>> removeDocument(String admissionId, String url);
}

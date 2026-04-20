import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/admission_entity.dart';
import '../../domain/repositories/admission_repository.dart';
import '../datasources/admission_remote_datasource.dart';
import '../models/admission_model.dart';

class AdmissionRepositoryImpl implements AdmissionRepository {
  final AdmissionRemoteDataSource remoteDataSource;

  AdmissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AdmissionEntity>>> getAdmissionsByPatient(String patientId) async {
    try {
      final results = await remoteDataSource.getAdmissionsByPatient(patientId);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<AdmissionEntity>> watchAdmissionsByPatient(String patientId) {
    return remoteDataSource.watchAdmissionsByPatient(patientId);
  }

  @override
  Stream<AdmissionEntity?> watchAdmission(String admissionId) {
    return remoteDataSource.watchAdmission(admissionId);
  }

  @override
  Future<Either<Failure, String>> requestAdmission(AdmissionEntity admission) async {
    try {
      final model = AdmissionModel(
        id: '',
        patientId: admission.patientId,
        reason: admission.reason,
        status: admission.status,
        createdAt: admission.createdAt,
        wardInfo: admission.wardInfo,
        notes: admission.notes,
        hospitalId: admission.hospitalId,
        doctorId: admission.doctorId,
        contactPhone: admission.contactPhone,
        emergencyContact: admission.emergencyContact,
        emergencyPhone: admission.emergencyPhone,
        admissionDate: admission.admissionDate,
        estimatedDischargeDate: admission.estimatedDischargeDate,
        documentUrls: admission.documentUrls,
        insuranceNumber: admission.insuranceNumber,
        priority: admission.priority,
      );
      final id = await remoteDataSource.createAdmissionRequest(model);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAdmissionStatus(String id, String status, {Map<String, dynamic>? extra}) async {
    try {
      await remoteDataSource.updateStatus(id, status, extra: extra);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument(String admissionId, String patientId, File file, String fileName) async {
    try {
      final url = await remoteDataSource.uploadDocument(admissionId, patientId, file, fileName);
      await remoteDataSource.addDocumentUrl(admissionId, url);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeDocument(String admissionId, String url) async {
    try {
      await remoteDataSource.removeDocumentUrl(admissionId, url);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

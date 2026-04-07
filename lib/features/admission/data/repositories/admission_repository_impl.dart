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
      );
      final id = await remoteDataSource.createAdmissionRequest(model);
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAdmissionStatus(String id, String status) async {
    try {
      await remoteDataSource.updateStatus(id, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

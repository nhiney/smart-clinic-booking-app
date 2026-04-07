import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../datasources/medical_record_remote_datasource.dart';
import '../datasources/medical_record_local_datasource.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final IMedicalRecordRemoteDataSource remoteDataSource;
  final IMedicalRecordLocalDataSource localDataSource;
  final INetworkInfo networkInfo;
  final AuthRepository authRepository;

  MedicalRecordRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, List<MedicalRecord>>> getRecords(String patientId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRecords = await remoteDataSource.getRecords(patientId);
        await localDataSource.cacheRecords(remoteRecords, patientId);
        return Right(remoteRecords);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localRecords = await localDataSource.getCachedRecords(patientId);
        return Right(localRecords);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadAttachment({
    required File file,
    required String recordId,
    required String patientId,
    required String fileName,
  }) async {
    // RBAC: Check user role - This is a safety check as per requirements.
    // Patients CAN upload to their own records.
    final currentUser = authRepository.getCurrentUser();
    if (currentUser == null) {
      return const Left(AuthFailure(message: 'Authentication required.'));
    }

    // Explicit check for write permissions (Patient vs Doctor) - In this module, 
    // we only allow Patients to upload attachments to their own records.
    if (currentUser.role == 'patient' && currentUser.id != patientId) {
      return const Left(PermissionFailure(
        message: 'You can only upload attachments to your own medical records.',
      ));
    }

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.uploadAttachment(
          file: file,
          recordId: recordId,
          patientId: patientId,
          fileName: fileName,
        );
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No internet connection for large file upload. Please retry later.',
      ));
    }
  }
}

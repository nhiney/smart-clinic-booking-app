import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medical_record.dart';
import '../repositories/medical_record_legacy_repository.dart';

class GetMedicalRecordsUseCase implements UseCase<List<MedicalRecord>, GetMedicalRecordsParams> {
  final MedicalRecordRepository repository;

  GetMedicalRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MedicalRecord>>> call(GetMedicalRecordsParams params) async {
    return await repository.getRecords(params.patientId);
  }
}

class GetMedicalRecordsParams extends Equatable {
  final String patientId;

  const GetMedicalRecordsParams({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}

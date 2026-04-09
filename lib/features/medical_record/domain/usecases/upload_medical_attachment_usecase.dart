import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/medical_record_legacy_repository.dart';

class UploadMedicalAttachmentUseCase implements UseCase<Unit, UploadMedicalAttachmentParams> {
  final MedicalRecordRepository repository;

  UploadMedicalAttachmentUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UploadMedicalAttachmentParams params) async {
    return await repository.uploadAttachment(
      file: params.file,
      recordId: params.recordId,
      patientId: params.patientId,
      fileName: params.fileName,
    );
  }
}

class UploadMedicalAttachmentParams extends Equatable {
  final File file;
  final String recordId;
  final String patientId;
  final String fileName;

  const UploadMedicalAttachmentParams({
    required this.file,
    required this.recordId,
    required this.patientId,
    required this.fileName,
  });

  @override
  List<Object?> get props => [file, recordId, patientId, fileName];
}

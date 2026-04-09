import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/medical_record.dart';

abstract class MedicalRecordRepository {
  /// Fetches all medical records for a specific patient.
  /// Returns [List<MedicalRecord>] or [Failure].
  Future<Either<Failure, List<MedicalRecord>>> getRecords(String patientId);

  /// Uploads an attachment to a specific medical record.
  /// Returns a stream of [double] representing upload progress (0.0 to 1.0)
  /// and the final [Attachment] on success.
  /// Since this is an abstract interface, we use a basic Either for the final result.
  Future<Either<Failure, Unit>> uploadAttachment({
    required File file,
    required String recordId,
    required String patientId,
    required String fileName,
  });
}

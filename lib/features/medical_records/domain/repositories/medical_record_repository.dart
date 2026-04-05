import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/medical_record.dart';

abstract class MedicalRecordRepository {
  Future<Either<Failure, List<MedicalRecord>>> getRecords(String patientId);
  Future<Either<Failure, String>> uploadAttachment(File file, String recordId);
  Future<Either<Failure, String>> shareRecord(String recordId);
}

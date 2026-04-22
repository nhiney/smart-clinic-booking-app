import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/failure.dart';
import '../entities/medical_record_entity.dart';
import '../entities/encounter_fhir.dart';
import '../entities/attachment.dart';
import '../entities/record_version.dart';
import '../entities/record_share.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalRecordEntity>> getMedicalRecords(String userId);
  Future<void> addMedicalRecord(MedicalRecordEntity record);
  Future<Either<Failure, List<EncounterFhir>>> getMedicalHistory(String patientId);

  // File attachments
  Stream<TaskSnapshot> uploadAttachment({
    required String recordId,
    required String patientId,
    required File file,
    required String fileName,
  });
  Future<List<Attachment>> getAttachments(String recordId);
  Future<void> deleteAttachment(String recordId, String attachmentId, String storagePath);

  // Versioning
  Future<void> createVersion(String recordId, MedicalRecordEntity record, {String changeNote});
  Future<List<RecordVersion>> getVersions(String recordId);

  // Sharing
  Future<RecordShare> shareRecord({
    required String recordId,
    required String ownerId,
    required String sharedWithId,
    required SharePermission permission,
    DateTime? expiresAt,
  });
  Future<List<RecordShare>> getSharedByMe(String ownerId);
  Future<List<RecordShare>> getSharedWithMe(String userId);
  Future<void> revokeShare(String shareId);
}

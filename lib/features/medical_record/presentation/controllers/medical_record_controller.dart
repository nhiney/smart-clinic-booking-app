import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/attachment.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/record_version.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/record_share.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/repositories/medical_record_repository.dart';
import '../riverpod/medical_history_provider.dart';

class MedicalRecordState {
  final bool isLoading;
  final List<MedicalRecordEntity> records;
  final Map<String, List<Attachment>> attachments;
  final Map<String, List<RecordVersion>> versions;
  final double uploadProgress;
  final bool isUploading;
  final String? error;

  const MedicalRecordState({
    this.isLoading = false,
    this.records = const [],
    this.attachments = const {},
    this.versions = const {},
    this.uploadProgress = 0,
    this.isUploading = false,
    this.error,
  });

  MedicalRecordState copyWith({
    bool? isLoading,
    List<MedicalRecordEntity>? records,
    Map<String, List<Attachment>>? attachments,
    Map<String, List<RecordVersion>>? versions,
    double? uploadProgress,
    bool? isUploading,
    String? error,
  }) {
    return MedicalRecordState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      attachments: attachments ?? this.attachments,
      versions: versions ?? this.versions,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }
}

final medicalRecordControllerProvider =
    StateNotifierProvider<MedicalRecordController, MedicalRecordState>((ref) {
  return MedicalRecordController(repository: ref.watch(medicalRecordRepositoryProvider));
});

class MedicalRecordController extends StateNotifier<MedicalRecordState> {
  final MedicalRecordRepository repository;

  MedicalRecordController({required this.repository}) : super(const MedicalRecordState());

  Future<void> fetchRecords(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await repository.getMedicalRecords(userId);
      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ─── ATTACHMENTS ─────────────────────────────────────────────────────────

  Future<void> loadAttachments(String recordId) async {
    try {
      final list = await repository.getAttachments(recordId);
      final updated = Map<String, List<Attachment>>.from(state.attachments);
      updated[recordId] = list;
      state = state.copyWith(attachments: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> uploadFile({
    required String recordId,
    required String patientId,
    required File file,
    required String fileName,
  }) async {
    state = state.copyWith(isUploading: true, uploadProgress: 0, error: null);
    try {
      final stream = repository.uploadAttachment(
        recordId: recordId,
        patientId: patientId,
        file: file,
        fileName: fileName,
      );

      await for (final snapshot in stream) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        state = state.copyWith(uploadProgress: progress);
        if (snapshot.state == TaskState.success) {
          await loadAttachments(recordId);
          state = state.copyWith(isUploading: false, uploadProgress: 1);
          return true;
        }
        if (snapshot.state == TaskState.error) {
          state = state.copyWith(isUploading: false, error: 'Upload failed');
          return false;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteAttachment(String recordId, String attachmentId, String storagePath) async {
    try {
      await repository.deleteAttachment(recordId, attachmentId, storagePath);
      await loadAttachments(recordId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── VERSIONING ───────────────────────────────────────────────────────────

  Future<void> loadVersions(String recordId) async {
    try {
      final list = await repository.getVersions(recordId);
      final updated = Map<String, List<RecordVersion>>.from(state.versions);
      updated[recordId] = list;
      state = state.copyWith(versions: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── SHARING ─────────────────────────────────────────────────────────────

  Future<RecordShare?> shareRecord({
    required String recordId,
    required String ownerId,
    required String sharedWithId,
    SharePermission permission = SharePermission.view,
    DateTime? expiresAt,
  }) async {
    try {
      return await repository.shareRecord(
        recordId: recordId,
        ownerId: ownerId,
        sharedWithId: sharedWithId,
        permission: permission,
        expiresAt: expiresAt,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> revokeShare(String shareId) async {
    try {
      await repository.revokeShare(shareId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

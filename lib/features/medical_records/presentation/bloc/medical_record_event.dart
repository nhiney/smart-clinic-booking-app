import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class MedicalRecordEvent extends Equatable {
  const MedicalRecordEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecordsEvent extends MedicalRecordEvent {
  final String patientId;

  const FetchRecordsEvent(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class UploadAttachmentEvent extends MedicalRecordEvent {
  final File file;
  final String recordId;
  final String patientId;
  final String fileName;

  const UploadAttachmentEvent({
    required this.file,
    required this.recordId,
    required this.patientId,
    required this.fileName,
  });

  @override
  List<Object?> get props => [file, recordId, patientId, fileName];
}

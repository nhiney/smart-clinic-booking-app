import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_record.dart';

abstract class MedicalRecordState extends Equatable {
  const MedicalRecordState();

  @override
  List<Object?> get props => [];
}

class MedicalRecordInitial extends MedicalRecordState {}

class MedicalRecordLoading extends MedicalRecordState {}

class MedicalRecordError extends MedicalRecordState {
  final String message;

  const MedicalRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicalRecordsLoaded extends MedicalRecordState {
  final List<MedicalRecord> records;
  final bool isOffline;

  const MedicalRecordsLoaded(this.records, {this.isOffline = false});

  @override
  List<Object?> get props => [records, isOffline];
}

class AttachmentUploadInProgress extends MedicalRecordState {}

class AttachmentUploadSuccess extends MedicalRecordState {
  final String downloadUrl;

  const AttachmentUploadSuccess(this.downloadUrl);

  @override
  List<Object?> get props => [downloadUrl];
}

class AttachmentUploadFailure extends MedicalRecordState {
  final String message;

  const AttachmentUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

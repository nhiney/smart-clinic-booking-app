import 'package:equatable/equatable.dart';
import 'attachment.dart';

enum MedicalRecordType {
  prescription,
  labResult,
  imaging,
  vitals,
  other,
}

class MedicalRecord extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String diagnosis;
  final MedicalRecordType type;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Attachment> attachments;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.diagnosis,
    required this.type,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        diagnosis,
        type,
        notes,
        createdAt,
        updatedAt,
        attachments,
      ];
}

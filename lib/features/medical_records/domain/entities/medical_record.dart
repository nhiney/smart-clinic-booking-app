import 'package:equatable/equatable.dart';

enum MedicalRecordType { lab, prescription, general }

class MedicalRecord extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String diagnosis;
  final MedicalRecordType type;
  final List<String> attachments;
  final int version;
  final DateTime createdAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.diagnosis,
    required this.type,
    required this.attachments,
    required this.version,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        diagnosis,
        type,
        attachments,
        version,
        createdAt,
      ];
}

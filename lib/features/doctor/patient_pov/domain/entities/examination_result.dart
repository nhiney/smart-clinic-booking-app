import 'package:equatable/equatable.dart';

class ExaminationResult extends Equatable {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime? examinedAt;

  const ExaminationResult({
    this.id = '',
    required this.appointmentId,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    required this.diagnosis,
    this.prescription = '',
    this.notes = '',
    this.examinedAt,
  });

  ExaminationResult copyWith({
    String? id,
    String? appointmentId,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? diagnosis,
    String? prescription,
    String? notes,
    DateTime? examinedAt,
  }) {
    return ExaminationResult(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
      examinedAt: examinedAt ?? this.examinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        patientId,
        patientName,
        doctorId,
        doctorName,
        diagnosis,
        prescription,
        notes,
        examinedAt,
      ];
}
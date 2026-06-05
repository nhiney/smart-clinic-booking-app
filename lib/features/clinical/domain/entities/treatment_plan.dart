import 'package:equatable/equatable.dart';

import 'medication_plan_item.dart';

class TreatmentPlan extends Equatable {
  final String id;
  final String encounterId;
  final String patientId;
  final String patientName;
  final String patientCode;
  final int patientAge;
  final String patientGender;
  final String diagnosisSummary;
  final List<String> icdCodes;
  final List<MedicationPlanItem> medications;
  final List<String> labTests;
  final List<String> imagingTests;
  final DateTime? followUpDate;
  final String notes;
  final String? exportedPdfPath;
  final DateTime updatedAt;

  const TreatmentPlan({
    required this.id,
    required this.encounterId,
    required this.patientId,
    required this.patientName,
    required this.patientCode,
    required this.patientAge,
    required this.patientGender,
    required this.diagnosisSummary,
    required this.icdCodes,
    required this.medications,
    required this.labTests,
    required this.imagingTests,
    required this.followUpDate,
    required this.notes,
    required this.exportedPdfPath,
    required this.updatedAt,
  });

  TreatmentPlan copyWith({
    String? diagnosisSummary,
    List<String>? icdCodes,
    List<MedicationPlanItem>? medications,
    List<String>? labTests,
    List<String>? imagingTests,
    DateTime? followUpDate,
    String? notes,
    String? exportedPdfPath,
    DateTime? updatedAt,
  }) {
    return TreatmentPlan(
      id: id,
      encounterId: encounterId,
      patientId: patientId,
      patientName: patientName,
      patientCode: patientCode,
      patientAge: patientAge,
      patientGender: patientGender,
      diagnosisSummary: diagnosisSummary ?? this.diagnosisSummary,
      icdCodes: icdCodes ?? this.icdCodes,
      medications: medications ?? this.medications,
      labTests: labTests ?? this.labTests,
      imagingTests: imagingTests ?? this.imagingTests,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      exportedPdfPath: exportedPdfPath ?? this.exportedPdfPath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        encounterId,
        patientId,
        patientName,
        patientCode,
        patientAge,
        patientGender,
        diagnosisSummary,
        icdCodes,
        medications,
        labTests,
        imagingTests,
        followUpDate,
        notes,
        exportedPdfPath,
        updatedAt,
      ];
}

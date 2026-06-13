import 'package:equatable/equatable.dart';

import './medication_plan_item.dart';

class ClinicalEncounter extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientCode;
  final int age;
  final String gender;
  final String diagnosisBadge;
  final String visitTimeLabel;
  final int visitCount;
  final String subjective;
  final String objective;
  final String assessment;
  final List<String> icdCodes;
  final List<MedicationPlanItem> medications;
  final List<String> labTests;
  final List<String> imagingTests;
  final DateTime? followUpDate;
  final String notes;
  final bool completed;
  final DateTime startedAt;
  final DateTime updatedAt;

  const ClinicalEncounter({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientCode,
    required this.age,
    required this.gender,
    required this.diagnosisBadge,
    required this.visitTimeLabel,
    required this.visitCount,
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.icdCodes,
    required this.medications,
    required this.labTests,
    required this.imagingTests,
    required this.followUpDate,
    required this.notes,
    required this.completed,
    required this.startedAt,
    required this.updatedAt,
  });

  ClinicalEncounter copyWith({
    String? patientName,
    String? patientCode,
    int? age,
    String? gender,
    String? diagnosisBadge,
    String? visitTimeLabel,
    int? visitCount,
    String? subjective,
    String? objective,
    String? assessment,
    List<String>? icdCodes,
    List<MedicationPlanItem>? medications,
    List<String>? labTests,
    List<String>? imagingTests,
    DateTime? followUpDate,
    String? notes,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return ClinicalEncounter(
      id: id,
      patientId: patientId,
      patientName: patientName ?? this.patientName,
      patientCode: patientCode ?? this.patientCode,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      diagnosisBadge: diagnosisBadge ?? this.diagnosisBadge,
      visitTimeLabel: visitTimeLabel ?? this.visitTimeLabel,
      visitCount: visitCount ?? this.visitCount,
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      icdCodes: icdCodes ?? this.icdCodes,
      medications: medications ?? this.medications,
      labTests: labTests ?? this.labTests,
      imagingTests: imagingTests ?? this.imagingTests,
      followUpDate: followUpDate ?? this.followUpDate,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        patientCode,
        age,
        gender,
        diagnosisBadge,
        visitTimeLabel,
        visitCount,
        subjective,
        objective,
        assessment,
        icdCodes,
        medications,
        labTests,
        imagingTests,
        followUpDate,
        notes,
        completed,
        startedAt,
        updatedAt,
      ];
}

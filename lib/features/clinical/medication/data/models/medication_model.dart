import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.patientId,
    required super.name,
    super.dosage,
    super.frequency,
    super.time,
    required super.startDate,
    super.endDate,
    super.isActive,
    super.notes,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json, String docId) {
    return MedicationModel(
      id: docId,
      patientId: json['patientId'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? 'Mỗi ngày',
      time: json['time'] ?? '08:00',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      isActive: json['isActive'] ?? true,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'notes': notes,
    };
  }
}

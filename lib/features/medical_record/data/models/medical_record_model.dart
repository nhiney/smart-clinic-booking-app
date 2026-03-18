import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medical_record_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  const MedicalRecordModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    super.doctorName,
    required super.diagnosis,
    super.prescription,
    super.notes,
    required super.date,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json, String docId) {
    return MedicalRecordModel(
      id: docId,
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      prescription: json['prescription'] ?? '',
      notes: json['notes'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'notes': notes,
      'date': Timestamp.fromDate(date),
    };
  }
}

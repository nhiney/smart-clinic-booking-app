import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  const MedicalRecordModel({
    required super.id,
    required super.userId,
    required super.doctor,
    required super.diagnosis,
    required super.prescription,
    required super.date,
    super.symptoms,
    super.notes,
  });

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      doctor: data['doctor'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      prescription: data['prescription'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      symptoms: (data['symptoms'] as List?)?.map((e) => e.toString()).toList(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'doctor': doctor,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'date': Timestamp.fromDate(date),
      'symptoms': symptoms,
      'notes': notes,
    };
  }
}

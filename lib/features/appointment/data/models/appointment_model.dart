import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.doctorId,
    super.doctorName,
    super.specialty,
    required super.dateTime,
    super.status,
    super.notes,
    super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return AppointmentModel(
      id: docId,
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'notes': notes,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}

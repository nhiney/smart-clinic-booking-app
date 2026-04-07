import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admission_entity.dart';

class AdmissionModel extends AdmissionEntity {
  const AdmissionModel({
    required super.id,
    required super.patientId,
    required super.reason,
    required super.status,
    required super.createdAt,
    super.wardInfo,
    super.notes,
  });

  factory AdmissionModel.fromJson(Map<String, dynamic> json, String docId) {
    return AdmissionModel(
      id: docId,
      patientId: json['patientId'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      wardInfo: json['wardInfo'] != null ? Map<String, dynamic>.from(json['wardInfo']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'wardInfo': wardInfo,
      'notes': notes,
    };
  }
}

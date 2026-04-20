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
    super.hospitalId,
    super.doctorId,
    super.contactPhone,
    super.emergencyContact,
    super.emergencyPhone,
    super.admissionDate,
    super.estimatedDischargeDate,
    super.actualDischargeDate,
    super.documentUrls,
    super.insuranceNumber,
    super.priority,
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
      hospitalId: json['hospitalId'],
      doctorId: json['doctorId'],
      contactPhone: json['contactPhone'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      admissionDate: json['admissionDate'] != null
          ? (json['admissionDate'] as Timestamp).toDate()
          : null,
      estimatedDischargeDate: json['estimatedDischargeDate'] != null
          ? (json['estimatedDischargeDate'] as Timestamp).toDate()
          : null,
      actualDischargeDate: json['actualDischargeDate'] != null
          ? (json['actualDischargeDate'] as Timestamp).toDate()
          : null,
      documentUrls: List<String>.from(json['documentUrls'] ?? []),
      insuranceNumber: json['insuranceNumber'],
      priority: json['priority'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (wardInfo != null) 'wardInfo': wardInfo,
      if (notes != null) 'notes': notes,
      if (hospitalId != null) 'hospitalId': hospitalId,
      if (doctorId != null) 'doctorId': doctorId,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (emergencyPhone != null) 'emergencyPhone': emergencyPhone,
      if (admissionDate != null) 'admissionDate': Timestamp.fromDate(admissionDate!),
      if (estimatedDischargeDate != null)
        'estimatedDischargeDate': Timestamp.fromDate(estimatedDischargeDate!),
      if (actualDischargeDate != null)
        'actualDischargeDate': Timestamp.fromDate(actualDischargeDate!),
      'documentUrls': documentUrls,
      if (insuranceNumber != null) 'insuranceNumber': insuranceNumber,
      'priority': priority ?? 'normal',
    };
  }
}

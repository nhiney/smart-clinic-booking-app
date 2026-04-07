import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medical_record.dart';
import 'attachment_model.dart';

class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.diagnosis,
    required super.type,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.attachments,
  });

  factory MedicalRecordModel.fromSnapshot(Map<String, dynamic> json, String id) {
    return MedicalRecordModel(
      id: id,
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      type: MedicalRecordType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MedicalRecordType.other,
      ),
      notes: json['notes'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      attachments: (json['attachments'] as List?)
              ?.map((e) => AttachmentModel.fromSnapshot(e, ''))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'type': type.toString().split('.').last,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'attachments': attachments
          .map((e) => AttachmentModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  // Helper for JSON caching (Shared_preferences doesn't handle Timestamp)
  factory MedicalRecordModel.fromLocalJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      diagnosis: json['diagnosis'],
      type: MedicalRecordType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MedicalRecordType.other,
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      attachments: (json['attachments'] as List)
          .map((e) => AttachmentModel(
                id: e['id'],
                name: e['name'],
                downloadUrl: e['downloadUrl'],
                fileType: e['fileType'],
                uploadedAt: DateTime.parse(e['uploadedAt']),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'diagnosis': diagnosis,
      'type': type.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attachments': attachments
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'downloadUrl': e.downloadUrl,
                'fileType': e.fileType,
                'uploadedAt': e.uploadedAt.toIso8601String(),
              })
          .toList(),
    };
  }
}

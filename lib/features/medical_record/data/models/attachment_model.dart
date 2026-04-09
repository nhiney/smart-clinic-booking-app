import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attachment.dart';

class AttachmentModel extends Attachment {
  const AttachmentModel({
    required super.id,
    required super.name,
    required super.downloadUrl,
    required super.fileType,
    required super.uploadedAt,
  });

  factory AttachmentModel.fromSnapshot(Map<String, dynamic> json, String id) {
    return AttachmentModel(
      id: id,
      name: json['name'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'downloadUrl': downloadUrl,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  factory AttachmentModel.fromEntity(Attachment entity) {
    return AttachmentModel(
      id: entity.id,
      name: entity.name,
      downloadUrl: entity.downloadUrl,
      fileType: entity.fileType,
      uploadedAt: entity.uploadedAt,
    );
  }
}

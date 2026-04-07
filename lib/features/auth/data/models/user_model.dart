import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.role,
    super.avatarUrl,
    super.hospitalId,
    super.idCardUrl,
    super.medicalCertUrl,
    super.verified,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'patient',
      avatarUrl: json['avatarUrl'] ?? '',
      hospitalId: json['hospitalId'],
      idCardUrl: json['idCardUrl'],
      medicalCertUrl: json['medicalCertUrl'],
      verified: json['verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'avatarUrl': avatarUrl,
      'hospitalId': hospitalId,
      'idCardUrl': idCardUrl,
      'medicalCertUrl': medicalCertUrl,
      'verified': verified,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      role: entity.role,
      avatarUrl: entity.avatarUrl,
      hospitalId: entity.hospitalId,
      idCardUrl: entity.idCardUrl,
      medicalCertUrl: entity.medicalCertUrl,
      verified: entity.verified,
      createdAt: entity.createdAt,
    );
  }
}

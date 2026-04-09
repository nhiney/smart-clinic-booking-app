import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    required super.name,
    super.phone,
    super.authProvider,
    super.role,
    super.tenantId,
    super.departmentId,
    super.specialty,
    super.experienceYears,
    super.bio,
    super.address,
    super.isVerified,
    super.status,
    super.avatarUrl,
    super.idCardUrl,
    super.medicalCertUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      authProvider: json['auth_provider'] ?? (json['email'] != null && (json['email'] as String).isNotEmpty ? 'email' : 'phone'),
      role: json['role'] ?? 'patient',
      tenantId: json['tenant_id'] ?? json['hospital_id'] ?? json['hospitalId'],
      departmentId: json['department_id'] ?? json['departmentId'],
      specialty: json['specialty'],
      experienceYears: json['experience_years'] ?? json['experienceYears'],
      bio: json['bio'] ?? json['description'],
      address: json['address'],
      isVerified: json['is_verified'] ?? json['verified'] ?? false,
      status: json['status'] ?? 'active',
      avatarUrl: json['avatarUrl'] ?? '',
      idCardUrl: json['idCardUrl'],
      medicalCertUrl: json['medicalCertUrl'],
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : (json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'auth_provider': authProvider,
      'role': role,
      'tenant_id': tenantId,
      'department_id': departmentId,
      'specialty': specialty,
      'experience_years': experienceYears,
      'bio': bio,
      'address': address,
      'is_verified': isVerified,
      'status': status,
      'avatarUrl': avatarUrl,
      'idCardUrl': idCardUrl,
      'medicalCertUrl': medicalCertUrl,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      authProvider: entity.authProvider,
      role: entity.role,
      tenantId: entity.tenantId,
      departmentId: entity.departmentId,
      specialty: entity.specialty,
      experienceYears: entity.experienceYears,
      bio: entity.bio,
      address: entity.address,
      isVerified: entity.isVerified,
      status: entity.status,
      avatarUrl: entity.avatarUrl,
      idCardUrl: entity.idCardUrl,
      medicalCertUrl: entity.medicalCertUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Data Model mở rộng từ [UserEntity] với serialization logic.
///
/// ### Bảo mật:
/// - [password] chỉ tồn tại ở Data Layer (field riêng của Model,
///   KHÔNG có trong domain Entity).
/// - [toJson()] **KHÔNG** include password → an toàn khi gửi lên Firestore.
/// - [toJsonWithPassword()] chỉ dùng khi cần lưu password hash lên Firestore
///   (e.g., migration, hoặc QR flow legacy).
/// - [toSecureJson()] / [fromSecureJson()] dùng cho local cache (Secure Storage).
class UserModel extends UserEntity {
  /// Password chỉ tồn tại ở Data Layer.
  /// Trong các flow mới, đây là hashed password (HMAC-SHA256).
  /// Trong legacy data, có thể là plaintext (backward compatible).
  final String? password;

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
    super.dateOfBirth,
    super.isVerified,
    super.status,
    super.avatarUrl,
    super.idCardUrl,
    super.medicalCertUrl,
    this.password,
    super.createdAt,
    super.updatedAt,
  });

  /// Parse một giá trị ngày từ Firestore (Timestamp) hoặc local cache
  /// (ISO 8601 string). Trả về `null` nếu không hợp lệ.
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parse từ Firestore document.
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
      dateOfBirth: _parseTimestamp(json['date_of_birth'] ?? json['dateOfBirth']),
      isVerified: json['is_verified'] ?? json['verified'] ?? false,
      status: json['status'] ?? 'active',
      avatarUrl: json['avatarUrl'] ?? '',
      idCardUrl: json['idCardUrl'],
      medicalCertUrl: json['medicalCertUrl'],
      password: json['password'],
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : (json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Parse từ Secure Storage (local cache).
  /// Không có Timestamp — dùng ISO 8601 string.
  factory UserModel.fromSecureJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      authProvider: json['auth_provider'] ?? 'phone',
      role: json['role'] ?? 'patient',
      tenantId: json['tenant_id'],
      departmentId: json['department_id'],
      specialty: json['specialty'],
      experienceYears: json['experience_years'],
      bio: json['bio'],
      address: json['address'],
      dateOfBirth: _parseTimestamp(json['date_of_birth']),
      isVerified: json['is_verified'] ?? false,
      status: json['status'] ?? 'active',
      avatarUrl: json['avatarUrl'] ?? '',
      idCardUrl: json['idCardUrl'],
      medicalCertUrl: json['medicalCertUrl'],
      // Password KHÔNG lưu trong secure cache
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Serialize cho Firestore — **KHÔNG** bao gồm password.
  ///
  /// Đây là method mặc định an toàn. Password sẽ KHÔNG bao giờ
  /// được gửi lên Firestore qua method này.
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
      'date_of_birth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'is_verified': isVerified,
      'status': status,
      'avatarUrl': avatarUrl,
      'idCardUrl': idCardUrl,
      'medical_cert_url': medicalCertUrl,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Serialize bao gồm password hash — **CHỈ DÙNG** khi migration
  /// hoặc flow legacy (QR token) cần lưu password hash lên Firestore.
  Map<String, dynamic> toJsonWithPassword() {
    final json = toJson();
    if (password != null) {
      json['password'] = password;
    }
    return json;
  }

  /// Serialize an toàn cho local cache (Secure Storage).
  /// Không dùng Firestore Timestamp — dùng ISO 8601 string.
  /// Không bao gồm password.
  Map<String, dynamic> toSecureJson() {
    return {
      'id': id,
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
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'is_verified': isVerified,
      'status': status,
      'avatarUrl': avatarUrl,
      'idCardUrl': idCardUrl,
      'medicalCertUrl': medicalCertUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
      dateOfBirth: entity.dateOfBirth,
      isVerified: entity.isVerified,
      status: entity.status,
      avatarUrl: entity.avatarUrl,
      idCardUrl: entity.idCardUrl,
      medicalCertUrl: entity.medicalCertUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? authProvider,
    String? role,
    String? tenantId,
    String? departmentId,
    String? specialty,
    int? experienceYears,
    String? bio,
    String? address,
    DateTime? dateOfBirth,
    bool? isVerified,
    String? status,
    String? avatarUrl,
    String? idCardUrl,
    String? medicalCertUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      departmentId: departmentId ?? this.departmentId,
      specialty: specialty ?? this.specialty,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      medicalCertUrl: medicalCertUrl ?? this.medicalCertUrl,
      password: password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

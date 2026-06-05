import 'package:equatable/equatable.dart';

/// Domain Entity đại diện cho người dùng trong hệ thống.
///
/// ### Lưu ý bảo mật:
/// - Entity **KHÔNG** chứa trường `password`.
///   Password chỉ tồn tại ở Data Layer (encrypted) và không bao giờ
///   được truyền lên Domain/Presentation layer.
/// - Sử dụng Equatable để so sánh value-based (thay vì reference).
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String authProvider; // 'phone' | 'email'
  final String role; // 'patient' | 'doctor' | 'admin'
  final String? tenantId; // hospital_id
  final String? departmentId;
  final String? specialty;
  final int? experienceYears;
  final String? bio; // mô tả hồ sơ nghề nghiệp
  final String? address;
  final DateTime? dateOfBirth; // ngày sinh (tuổi tính ra từ field này)
  final bool isVerified;
  final String status; // 'active' | 'suspended'
  final String avatarUrl;
  final String? idCardUrl;
  final String? medicalCertUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    this.email = '',
    required this.name,
    this.phone = '',
    this.authProvider = 'phone',
    this.role = 'patient',
    this.tenantId,
    this.departmentId,
    this.specialty,
    this.experienceYears,
    this.bio,
    this.address,
    this.dateOfBirth,
    this.isVerified = false,
    this.status = 'active',
    this.avatarUrl = '',
    this.idCardUrl,
    this.medicalCertUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Tuổi tính từ [dateOfBirth]. Trả về `null` nếu chưa có ngày sinh.
  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  /// Tạo bản sao với các field được thay đổi.
  UserEntity copyWith({
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
    return UserEntity(
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, email, name, phone, authProvider, role,
        tenantId, departmentId, specialty, experienceYears,
        bio, address, dateOfBirth, isVerified, status, avatarUrl,
        idCardUrl, medicalCertUrl, createdAt, updatedAt,
      ];
}

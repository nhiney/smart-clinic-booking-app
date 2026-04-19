class UserEntity {
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
  final bool isVerified;
  final String status; // 'active' | 'suspended'
  final String avatarUrl;
  final String? idCardUrl;
  final String? medicalCertUrl;
  final String? password;
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
    this.isVerified = false,
    this.status = 'active',
    this.avatarUrl = '',
    this.idCardUrl,
    this.medicalCertUrl,
    this.password,
    this.createdAt,
    this.updatedAt,
  });
}

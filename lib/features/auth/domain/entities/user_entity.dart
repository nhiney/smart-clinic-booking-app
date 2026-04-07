class UserEntity {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String avatarUrl;
  final String? hospitalId;
  final String? idCardUrl;
  final String? medicalCertUrl;
  final bool verified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.role = 'patient',
    this.avatarUrl = '',
    this.hospitalId,
    this.idCardUrl,
    this.medicalCertUrl,
    this.verified = false,
    this.createdAt,
  });
}

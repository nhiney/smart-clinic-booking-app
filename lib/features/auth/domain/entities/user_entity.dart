class UserEntity {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String avatarUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.role = 'patient',
    this.avatarUrl = '',
    this.createdAt,
  });
}

class ClinicEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String imageUrl;
  final double rating;
  final List<String> specialties;
  final String openHours;

  const ClinicEntity({
    required this.id,
    required this.name,
    this.address = '',
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.specialties = const [],
    this.openHours = '08:00 - 17:00',
  });
}

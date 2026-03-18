class DoctorEntity {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int experience;
  final String about;
  final double latitude;
  final double longitude;
  final String phone;
  final List<String> availableDays;
  final List<String> availableTimeSlots;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialty,
    this.hospital = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.experience = 0,
    this.about = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.phone = '',
    this.availableDays = const [],
    this.availableTimeSlots = const [],
  });
}

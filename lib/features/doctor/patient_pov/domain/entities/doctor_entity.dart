/// Single day entry in a doctor's working schedule (Firestore `schedule` array).
class DoctorScheduleDay {
  final String day;
  final List<String> slots;

  const DoctorScheduleDay({
    required this.day,
    this.slots = const [],
  });
}

class DoctorEntity {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int totalReviews;
  final int experience;
  final String about;
  final String resumePdfUrl;
  final String departmentId;
  final double latitude;
  final double longitude;
  final String phone;
  final List<String> availableDays;
  final List<String> availableTimeSlots;
  /// Display name of clinic / practice (Firestore `clinicName`).
  final String clinicName;
  /// Human-readable address or region (Firestore `location` when string).
  final String location;
  /// Structured weekly schedule; preferred over [availableDays] / [availableTimeSlots].
  final List<DoctorScheduleDay> schedule;
  /// Filled client-side when sorting by distance (km).
  final double? distanceKm;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialty,
    this.hospital = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.experience = 0,
    this.about = '',
    this.resumePdfUrl = '',
    this.departmentId = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.phone = '',
    this.availableDays = const [],
    this.availableTimeSlots = const [],
    this.clinicName = '',
    this.location = '',
    this.schedule = const [],
    this.distanceKm,
  });

  /// Clinic line for UI: prefers [clinicName], then [hospital].
  String get displayClinic {
    if (clinicName.isNotEmpty) return clinicName;
    return hospital;
  }
}

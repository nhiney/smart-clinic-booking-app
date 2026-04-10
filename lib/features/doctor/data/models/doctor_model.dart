import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    super.hospital,
    super.imageUrl,
    super.rating,
    super.totalReviews,
    super.experience,
    super.about,
    super.resumePdfUrl,
    super.departmentId,
    super.latitude,
    super.longitude,
    super.phone,
    super.availableDays,
    super.availableTimeSlots,
    super.clinicName,
    super.location,
    super.schedule,
    super.distanceKm,
  });

  static List<DoctorScheduleDay> _parseSchedule(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    final out = <DoctorScheduleDay>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final day = m['day']?.toString() ?? '';
      final slotRaw = m['slots'];
      final slots = slotRaw is List
          ? slotRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : <String>[];
      if (day.isEmpty) continue;
      out.add(DoctorScheduleDay(day: day, slots: slots));
    }
    return out;
  }

  static String _stringifyLocationField(dynamic loc, double lat, double lng) {
    if (loc == null) return '';
    if (loc is String) return loc;
    if (loc is GeoPoint) {
      if (lat == 0 && lng == 0) return '';
      return '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
    }
    return loc.toString();
  }

  /// Maps Firestore `doctors` documents (catalog + legacy field names).
  factory DoctorModel.fromJson(Map<String, dynamic> json, String docId) {
    double lat = (json['latitude'] ?? 0).toDouble();
    double lng = (json['longitude'] ?? 0).toDouble();
    final locField = json['location'];
    if (locField is GeoPoint) {
      lat = locField.latitude;
      lng = locField.longitude;
    }

    final clinic =
        (json['clinicName'] ?? json['clinic_name'] ?? '').toString();
    final legacyHospital = (json['hospital'] ?? '').toString();
    final resolvedHospital =
        legacyHospital.isNotEmpty ? legacyHospital : clinic;

    final imageUrl = (json['avatarUrl'] ??
            json['imageUrl'] ??
            json['image_url'] ??
            '')
        .toString();

    final description = (json['description'] ?? json['about'] ?? '').toString();
    final experienceVal = json['experienceYears'] ?? json['experience'] ?? 0;
    final experience = experienceVal is int
        ? experienceVal
        : int.tryParse('$experienceVal') ?? 0;

    final totalReviewsRaw = json['totalReviews'] ?? json['total_reviews'] ?? 0;
    final totalReviews = totalReviewsRaw is int
        ? totalReviewsRaw
        : int.tryParse('$totalReviewsRaw') ?? 0;

    final schedule = _parseSchedule(json['schedule']);

    return DoctorModel(
      id: (json['doctorId'] ?? docId).toString(),
      name: (json['name'] ?? '').toString(),
      specialty: (json['specialty'] ?? '').toString(),
      hospital: resolvedHospital,
      imageUrl: imageUrl,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse('${json['rating']}') ?? 0.0,
      totalReviews: totalReviews,
      experience: experience,
      about: description,
      resumePdfUrl: (json['resumePdfUrl'] ?? json['resume_pdf_url'] ?? '')
          .toString(),
      departmentId: (json['departmentId'] ?? json['department_id'] ?? '')
          .toString(),
      latitude: lat,
      longitude: lng,
      phone: (json['phone'] ?? '').toString(),
      availableDays: List<String>.from(json['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(json['availableTimeSlots'] ?? []),
      clinicName: clinic,
      location: _stringifyLocationField(locField, lat, lng),
      schedule: schedule,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': id,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'clinicName': clinicName.isNotEmpty ? clinicName : hospital,
      'avatarUrl': imageUrl,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'experienceYears': experience,
      'description': about,
      'resumePdfUrl': resumePdfUrl,
      'departmentId': departmentId,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'location': location,
      'schedule': schedule
          .map((e) => {'day': e.day, 'slots': e.slots})
          .toList(),
    };
  }
}

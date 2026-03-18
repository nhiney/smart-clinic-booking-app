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
    super.experience,
    super.about,
    super.latitude,
    super.longitude,
    super.phone,
    super.availableDays,
    super.availableTimeSlots,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json, String docId) {
    return DoctorModel(
      id: docId,
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      hospital: json['hospital'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      experience: json['experience'] ?? 0,
      about: json['about'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
      availableDays: List<String>.from(json['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(json['availableTimeSlots'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'imageUrl': imageUrl,
      'rating': rating,
      'experience': experience,
      'about': about,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
    };
  }
}

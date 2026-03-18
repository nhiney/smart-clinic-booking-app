import '../../domain/entities/clinic_entity.dart';

class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.name,
    super.address,
    required super.latitude,
    required super.longitude,
    super.phone,
    super.imageUrl,
    super.rating,
    super.specialties,
    super.openHours,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json, String id) {
    return ClinicModel(
      id: id,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      openHours: json['openHours'] ?? '08:00 - 17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'imageUrl': imageUrl,
      'rating': rating,
      'specialties': specialties,
      'openHours': openHours,
    };
  }
}

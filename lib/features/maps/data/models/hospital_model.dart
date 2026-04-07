import '../../domain/entities/hospital_entity.dart';

class HospitalModel extends HospitalEntity {
  const HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    required super.lat,
    required super.lng,
    required super.specialties,
    required super.rating,
    required super.isOpen,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Chưa cập nhật',
      address: json['address'] as String? ?? 'Chưa cập nhật',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      specialties: (json['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'specialties': specialties,
      'rating': rating,
      'isOpen': isOpen,
    };
  }
}

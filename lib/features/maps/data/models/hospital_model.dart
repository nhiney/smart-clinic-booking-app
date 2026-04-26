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
    super.featured = false,
    super.imageUrl,
    super.description,
    super.phone,
    super.workingHours,
    super.distance,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: (json['id'] ?? json['hospitalId'] ?? '').toString(),
      name: json['name'] as String? ?? 'Chưa cập nhật',
      address: json['address'] as String? ?? 'Chưa cập nhật',
      lat: (json['lat'] ?? json['latitude'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] ?? json['longitude'] as num?)?.toDouble() ?? 0.0,
      specialties: (json['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      workingHours: json['workingHours'] as String?,
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
      'featured': featured,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (workingHours != null) 'workingHours': workingHours,
      if (distance != null) 'distance': distance,
    };
  }
}

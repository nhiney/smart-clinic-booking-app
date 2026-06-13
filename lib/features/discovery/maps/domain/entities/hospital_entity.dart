import 'package:equatable/equatable.dart';

class HospitalEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List<String> specialties;
  final double rating;
  final bool isOpen;
  final bool featured;

  final String? imageUrl;
  final String? description;
  final String? phone;
  final String? workingHours;
  final double? distance;

  const HospitalEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.specialties,
    required this.rating,
    required this.isOpen,
    this.featured = false,
    this.imageUrl,
    this.description,
    this.phone,
    this.workingHours,
    this.distance,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        lat,
        lng,
        specialties,
        rating,
        isOpen,
        featured,
        imageUrl,
        description,
        phone,
        workingHours,
        distance,
      ];
}

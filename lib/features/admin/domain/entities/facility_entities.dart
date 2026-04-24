import 'package:equatable/equatable.dart';

class Hospital extends Equatable {
  final String id;
  final String name;
  final String address;
  final String logoUrl;
  final String imageUrl;
  final String description;
  final String phone;
  final String workingHours;
  final List<String> specialties;
  final double rating;
  final bool isOpen;
  final bool featured;

  const Hospital({
    required this.id,
    required this.name,
    this.address = '',
    this.logoUrl = '',
    this.imageUrl = '',
    this.description = '',
    this.phone = '',
    this.workingHours = '',
    this.specialties = const [],
    this.rating = 0.0,
    this.isOpen = true,
    this.featured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'logoUrl': logoUrl,
      'imageUrl': imageUrl,
      'description': description,
      'phone': phone,
      'workingHours': workingHours,
      'specialties': specialties,
      'rating': rating,
      'isOpen': isOpen,
      'featured': featured,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map, String id) {
    return Hospital(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      workingHours: map['workingHours'] ?? '',
      specialties: (map['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: map['isOpen'] ?? true,
      featured: map['featured'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        logoUrl,
        imageUrl,
        description,
        phone,
        workingHours,
        specialties,
        rating,
        isOpen,
        featured,
      ];
}

class Department extends Equatable {
  final String id;
  final String hospitalId;
  final String name;
  final String description;

  const Department({
    required this.id,
    required this.hospitalId,
    required this.name,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'name': name,
      'description': description,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map, String id) {
    return Department(
      id: id,
      hospitalId: map['hospitalId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, hospitalId, name, description];
}

class Room extends Equatable {
  final String id;
  final String departmentId;
  final String name;
  final String type; // e.g., 'Examination', 'Emergency', 'ICU'

  const Room({
    required this.id,
    required this.departmentId,
    required this.name,
    this.type = 'Examination',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departmentId': departmentId,
      'name': name,
      'type': type,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      id: id,
      departmentId: map['departmentId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Examination',
    );
  }

  @override
  List<Object?> get props => [id, departmentId, name, type];
}

class Device extends Equatable {
  final String id;
  final String roomId;
  final String name;
  final String status; // 'active', 'maintenance', 'inactive'

  const Device({
    required this.id,
    required this.roomId,
    required this.name,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'name': name,
      'status': status,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map, String id) {
    return Device(
      id: id,
      roomId: map['roomId'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, roomId, name, status];
}

import '../../domain/entities/clinic_room_entity.dart';

class ClinicRoomModel extends ClinicRoomEntity {
  const ClinicRoomModel({
    required super.id,
    required super.name,
    super.floor,
    super.type,
    super.status,
    super.workingHours,
  });

  factory ClinicRoomModel.fromJson(Map<String, dynamic> json, String docId) {
    return ClinicRoomModel(
      id: (json['id'] ?? docId) as String,
      name: (json['name'] as String?) ?? '',
      floor: (json['floor'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'examination',
      status: (json['status'] as String?) ?? 'available',
      workingHours: (json['workingHours'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor': floor,
      'type': type,
      'status': status,
      'workingHours': workingHours,
    };
  }
}

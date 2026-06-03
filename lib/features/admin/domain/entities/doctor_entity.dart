import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String name;
  final String specialty;

  const Doctor({
    required this.id,
    required this.name,
    this.specialty = '',
  });

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, specialty];
}
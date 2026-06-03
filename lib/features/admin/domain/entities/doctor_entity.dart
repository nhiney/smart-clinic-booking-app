import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final String hospitalName;
  final int experienceYears;
  final String status;
  final dynamic createdAt;
  final dynamic approvedAt;

  const Doctor({
    required this.id,
    required this.name,
    this.specialty = '',
    this.hospitalName = '',
    this.experienceYears = 0,
    this.status = 'pending',
    this.createdAt,
    this.approvedAt,
  });

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      name: map['name'] ?? map['fullName'] ?? '',
      specialty: map['specialty'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      experienceYears: (map['experienceYears'] ?? 0) as int,
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'],
      approvedAt: map['approvedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'hospitalName': hospitalName,
      'experienceYears': experienceYears,
      'status': status,
      'createdAt': createdAt,
      'approvedAt': approvedAt,
    };
  }

  @override
  List<Object?> get props => [id, name, specialty, hospitalName, experienceYears, status, createdAt, approvedAt];
}
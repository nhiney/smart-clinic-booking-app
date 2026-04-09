import 'package:equatable/equatable.dart';

class MedicalRecordEntity extends Equatable {
  final String id;
  final String userId;
  final String doctor;
  final String diagnosis;
  final String prescription;
  final DateTime createdAt;
  final List<String>? symptoms;
  final String? notes;

  const MedicalRecordEntity({
    required this.id,
    required this.userId,
    required this.doctor,
    required this.diagnosis,
    required this.prescription,
    required this.createdAt,
    this.symptoms,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, doctor, diagnosis, prescription, createdAt, symptoms, notes];
}

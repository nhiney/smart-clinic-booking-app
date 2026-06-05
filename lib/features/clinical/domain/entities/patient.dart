import 'package:equatable/equatable.dart';
import 'medical_record.dart';
import 'vital_sign.dart';

class Patient extends Equatable {
  final String id;
  final String code;
  final String fullName;
  final int age;
  final String gender;
  final String bloodGroup;
  final double weight;
  final double bmi;
  final VitalSign latestVital;
  final List<String> symptoms;
  final List<MedicalRecord> records;
  final String? avatarUrl;

  const Patient({
    required this.id,
    required this.code,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.weight,
    required this.bmi,
    required this.latestVital,
    required this.symptoms,
    required this.records,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        fullName,
        age,
        gender,
        bloodGroup,
        weight,
        bmi,
        latestVital,
        symptoms,
        records,
        avatarUrl,
      ];
}

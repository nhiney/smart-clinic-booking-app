import 'package:equatable/equatable.dart';

class PatientFhir extends Equatable {
  final String id;
  final List<Map<String, String>> identifier;
  final List<Map<String, String>> name;
  final String gender;
  final DateTime birthDate;
  final List<Map<String, String>> telecom;

  const PatientFhir({
    required this.id,
    required this.identifier,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.telecom,
  });

  @override
  List<Object?> get props => [id, identifier, name, gender, birthDate, telecom];

  factory PatientFhir.fromJson(Map<String, dynamic> json) {
    return PatientFhir(
      id: json['id'] as String,
      identifier: List<Map<String, String>>.from(
        (json['identifier'] as List).map((e) => Map<String, String>.from(e as Map)),
      ),
      name: List<Map<String, String>>.from(
        (json['name'] as List).map((e) => Map<String, String>.from(e as Map)),
      ),
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      telecom: List<Map<String, String>>.from(
        (json['telecom'] as List).map((e) => Map<String, String>.from(e as Map)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Patient',
      'id': id,
      'identifier': identifier,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String().split('T')[0],
      'telecom': telecom,
    };
  }
}

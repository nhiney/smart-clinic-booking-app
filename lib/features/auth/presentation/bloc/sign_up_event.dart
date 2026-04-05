import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class ToggleRoleEvent extends SignUpEvent {}

class ToggleLanguageEvent extends SignUpEvent {} // Event for multi-language toggle

class SubmitPatientRegistration extends SignUpEvent {
  final String phoneNumber;
  final String fullName;

  const SubmitPatientRegistration({
    required this.phoneNumber,
    required this.fullName,
  });

  @override
  List<Object> get props => [phoneNumber, fullName];
}

class SubmitDoctorRegistration extends SignUpEvent {
  final String email;
  final String password;
  final String fullName;
  final String targetHospitalId;

  const SubmitDoctorRegistration({
    required this.email,
    required this.password,
    required this.fullName,
    required this.targetHospitalId,
  });

  @override
  List<Object> get props => [email, password, fullName, targetHospitalId];
}

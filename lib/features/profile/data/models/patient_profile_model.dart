import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    required super.fullName,
    required super.phone,
    super.dob,
    super.gender,
    super.address,
    super.bloodType,
    super.allergies,
    super.medicalHistory,
    super.email,
    super.receiveEmail,
    super.cloudStorageEnabled,
  });

  factory PatientProfileModel.fromMap(Map<String, dynamic> map) {
    return PatientProfileModel(
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      gender: map['gender'],
      address: map['address'],
      bloodType: map['bloodType'],
      allergies: map['allergies'],
      medicalHistory: map['medicalHistory'],
      email: map['email'],
      receiveEmail: map['receiveEmail'] ?? false,
      cloudStorageEnabled: map['cloudStorageEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'gender': gender,
      'address': address,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'email': email,
      'receiveEmail': receiveEmail,
      'cloudStorageEnabled': cloudStorageEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory PatientProfileModel.fromEntity(PatientProfile entity) {
    return PatientProfileModel(
      fullName: entity.fullName,
      phone: entity.phone,
      dob: entity.dob,
      gender: entity.gender,
      address: entity.address,
      bloodType: entity.bloodType,
      allergies: entity.allergies,
      medicalHistory: entity.medicalHistory,
      email: entity.email,
      receiveEmail: entity.receiveEmail,
      cloudStorageEnabled: entity.cloudStorageEnabled,
    );
  }
}

class PatientProfile {
  final String fullName;
  final String phone;
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? bloodType;
  final String? allergies;
  final String? medicalHistory;
  final String? email;
  final bool receiveEmail;
  final bool cloudStorageEnabled;

  const PatientProfile({
    required this.fullName,
    required this.phone,
    this.dob,
    this.gender,
    this.address,
    this.bloodType,
    this.allergies,
    this.medicalHistory,
    this.email,
    this.receiveEmail = false,
    this.cloudStorageEnabled = false,
  });

  PatientProfile copyWith({
    String? fullName,
    String? phone,
    DateTime? dob,
    String? gender,
    String? address,
    String? bloodType,
    String? allergies,
    String? medicalHistory,
    String? email,
    bool? receiveEmail,
    bool? cloudStorageEnabled,
  }) {
    return PatientProfile(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      email: email ?? this.email,
      receiveEmail: receiveEmail ?? this.receiveEmail,
      cloudStorageEnabled: cloudStorageEnabled ?? this.cloudStorageEnabled,
    );
  }

  /// Returns an empty profile for first-time setup
  factory PatientProfile.empty(String phone) {
    return PatientProfile(
      fullName: '',
      phone: phone,
    );
  }
}

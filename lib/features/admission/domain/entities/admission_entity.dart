class AdmissionEntity {
  final String id;
  final String patientId;
  final String reason;
  final String status; // pending | approved | rejected | admitted | discharged
  final DateTime createdAt;
  final Map<String, dynamic>? wardInfo;
  final String? notes;
  final String? hospitalId;
  final String? doctorId;
  final String? contactPhone;
  final String? emergencyContact;
  final String? emergencyPhone;
  final DateTime? admissionDate;
  final DateTime? estimatedDischargeDate;
  final DateTime? actualDischargeDate;
  final List<String> documentUrls;
  final String? insuranceNumber;
  final String? priority; // normal | urgent | emergency

  const AdmissionEntity({
    required this.id,
    required this.patientId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.wardInfo,
    this.notes,
    this.hospitalId,
    this.doctorId,
    this.contactPhone,
    this.emergencyContact,
    this.emergencyPhone,
    this.admissionDate,
    this.estimatedDischargeDate,
    this.actualDischargeDate,
    this.documentUrls = const [],
    this.insuranceNumber,
    this.priority = 'normal',
  });

  AdmissionEntity copyWith({
    String? status,
    Map<String, dynamic>? wardInfo,
    String? notes,
    String? doctorId,
    DateTime? admissionDate,
    DateTime? estimatedDischargeDate,
    DateTime? actualDischargeDate,
    List<String>? documentUrls,
    String? priority,
  }) {
    return AdmissionEntity(
      id: id,
      patientId: patientId,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
      wardInfo: wardInfo ?? this.wardInfo,
      notes: notes ?? this.notes,
      hospitalId: hospitalId,
      doctorId: doctorId ?? this.doctorId,
      contactPhone: contactPhone,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      admissionDate: admissionDate ?? this.admissionDate,
      estimatedDischargeDate: estimatedDischargeDate ?? this.estimatedDischargeDate,
      actualDischargeDate: actualDischargeDate ?? this.actualDischargeDate,
      documentUrls: documentUrls ?? this.documentUrls,
      insuranceNumber: insuranceNumber,
      priority: priority ?? this.priority,
    );
  }
}

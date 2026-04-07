class AdmissionEntity {
  final String id;
  final String patientId;
  final String reason;
  final String status; // pending | approved | rejected | admitted | discharged
  final DateTime createdAt;
  final Map<String, dynamic>? wardInfo;
  final String? notes;

  const AdmissionEntity({
    required this.id,
    required this.patientId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.wardInfo,
    this.notes,
  });

  AdmissionEntity copyWith({
    String? status,
    Map<String, dynamic>? wardInfo,
    String? notes,
  }) {
    return AdmissionEntity(
      id: id,
      patientId: patientId,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
      wardInfo: wardInfo ?? this.wardInfo,
      notes: notes ?? this.notes,
    );
  }
}

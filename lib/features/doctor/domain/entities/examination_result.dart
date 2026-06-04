class ExaminationResult {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime? examinedAt;

  const ExaminationResult({
    this.id = '',
    required this.appointmentId,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    required this.diagnosis,
    this.prescription = '',
    this.notes = '',
    this.examinedAt,
  });
}
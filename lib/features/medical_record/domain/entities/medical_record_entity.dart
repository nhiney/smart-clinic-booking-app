class MedicalRecordEntity {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String prescription;
  final String notes;
  final DateTime date;

  const MedicalRecordEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.doctorName = '',
    required this.diagnosis,
    this.prescription = '',
    this.notes = '',
    required this.date,
  });
}

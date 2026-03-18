class MedicationEntity {
  final String id;
  final String patientId;
  final String name;
  final String dosage;
  final String frequency;
  final String time;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String notes;

  const MedicationEntity({
    required this.id,
    required this.patientId,
    required this.name,
    this.dosage = '',
    this.frequency = 'Mỗi ngày',
    this.time = '08:00',
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes = '',
  });
}

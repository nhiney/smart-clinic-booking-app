class AppointmentEntity {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;
  final String notes;
  final DateTime? createdAt;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    this.specialty = '',
    required this.dateTime,
    this.status = 'pending',
    this.notes = '',
    this.createdAt,
  });

  AppointmentEntity copyWith({
    String? status,
    DateTime? dateTime,
    String? notes,
  }) {
    return AppointmentEntity(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

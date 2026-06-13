class CheckInEntity {
  final String appointmentId;
  final String patientId;
  final String token;
  final DateTime validFrom;
  final DateTime expiresAt;
  final DateTime? checkedInAt;

  const CheckInEntity({
    required this.appointmentId,
    required this.patientId,
    required this.token,
    required this.validFrom,
    required this.expiresAt,
    this.checkedInAt,
  });

  bool get isWithinWindow {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(expiresAt);
  }
}

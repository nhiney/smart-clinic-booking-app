class CheckInResultEntity {
  final String bookingId;
  final String patientName;
  final String doctorName;
  final String queueNumber; // Số thứ tự khám (X)
  final DateTime checkInTime;

  CheckInResultEntity({
    required this.bookingId,
    required this.patientName,
    required this.doctorName,
    required this.queueNumber,
    required this.checkInTime,
  });
}

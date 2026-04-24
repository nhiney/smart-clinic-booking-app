import 'package:equatable/equatable.dart';

class CheckInResultEntity extends Equatable {
  final String appointmentId;
  final String patientName;
  final String patientPhone;
  final String doctorName;
  final String queueNumber;
  final DateTime scheduledTime;
  final DateTime checkInTime;

  const CheckInResultEntity({
    required this.appointmentId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorName,
    required this.queueNumber,
    required this.scheduledTime,
    required this.checkInTime,
  });

  @override
  List<Object?> get props => [
    appointmentId,
    patientName,
    patientPhone,
    doctorName,
    queueNumber,
    scheduledTime,
    checkInTime,
  ];
}

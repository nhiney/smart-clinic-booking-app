import 'package:equatable/equatable.dart';

class CheckInResultEntity extends Equatable {
  final String appointmentId;
  final String patientName;
  final String patientPhone;
  final DateTime scheduledTime;
  final DateTime checkInTime;

  const CheckInResultEntity({
    required this.appointmentId,
    required this.patientName,
    required this.patientPhone,
    required this.scheduledTime,
    required this.checkInTime,
  });

  @override
  List<Object?> get props => [
    appointmentId,
    patientName,
    patientPhone,
    scheduledTime,
    checkInTime,
  ];
}

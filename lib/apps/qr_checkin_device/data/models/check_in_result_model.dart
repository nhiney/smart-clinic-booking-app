import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/entities/check_in_result_entity.dart';

class CheckInResultModel extends CheckInResultEntity {
  CheckInResultModel({
    required super.appointmentId,
    required super.patientName,
    required super.patientPhone,
    required super.doctorName,
    required super.queueNumber,
    required super.scheduledTime,
    required super.checkInTime,
  });

  factory CheckInResultModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
    String patientName,
    String doctorName,
  ) {
    return CheckInResultModel(
      appointmentId: id,
      patientName: patientName,
      patientPhone: data['patientPhone']?.toString() ?? '',
      doctorName: doctorName,
      queueNumber: data['queueNumber']?.toString() ?? 'N/A',
      scheduledTime: data['scheduledTime'] != null
          ? (data['scheduledTime'] as Timestamp).toDate()
          : DateTime.now(),
      checkInTime: data['checkInTime'] != null
          ? (data['checkInTime'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

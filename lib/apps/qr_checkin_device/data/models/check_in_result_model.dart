import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/entities/check_in_result_entity.dart';

class CheckInResultModel extends CheckInResultEntity {
  CheckInResultModel({
    required super.bookingId,
    required super.patientName,
    required super.doctorName,
    required super.queueNumber,
    required super.checkInTime,
  });

  factory CheckInResultModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
    String patientName,
    String doctorName,
  ) {
    return CheckInResultModel(
      bookingId: id,
      patientName: patientName,
      doctorName: doctorName,
      queueNumber: data['queueNumber']?.toString() ?? 'N/A',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
    );
  }
}

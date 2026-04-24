import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/check_in_result_entity.dart';

class CheckInModel extends CheckInResultEntity {
  const CheckInModel({
    required super.appointmentId,
    required super.patientName,
    required super.patientPhone,
    required super.doctorName,
    required super.queueNumber,
    required super.scheduledTime,
    required super.checkInTime,
  });

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final scheduledTs = data['scheduledTime'] as Timestamp?;
    final checkInTs = data['checkInTime'] as Timestamp?;

    return CheckInModel(
      appointmentId: doc.id,
      patientName: data['patientName'] ?? 'N/A',
      patientPhone: data['patientPhone'] ?? 'N/A',
      doctorName: data['doctorName'] ?? 'N/A',
      queueNumber: data['queueNumber']?.toString() ?? 'N/A',
      scheduledTime: scheduledTs?.toDate() ?? DateTime.now(),
      checkInTime: checkInTs?.toDate() ?? DateTime.now(),
    );
  }

  CheckInResultEntity toEntity() => this;
}

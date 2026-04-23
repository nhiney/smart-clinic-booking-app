import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/check_in_result_entity.dart';

class CheckInModel extends CheckInResultEntity {
  const CheckInModel({
    required super.appointmentId,
    required super.patientName,
    required super.patientPhone,
    required super.scheduledTime,
    required super.checkInTime,
  });

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle potential nulls or Timestamp conversions
    final scheduledTs = data['scheduledTime'] as Timestamp?;
    final checkInTs = data['checkInTime'] as Timestamp?;

    return CheckInModel(
      appointmentId: doc.id,
      patientName: data['patientName'] ?? 'N/A',
      patientPhone: data['patientPhone'] ?? 'N/A',
      scheduledTime: scheduledTs?.toDate() ?? DateTime.now(),
      checkInTime: checkInTs?.toDate() ?? DateTime.now(),
    );
  }

  CheckInResultEntity toEntity() => this;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.doctorId,
    super.doctorName,
    super.specialty,
    required super.dateTime,
    super.status,
    super.notes,
    super.createdAt,
    super.queueNumber,
    super.estimatedWaitTimeMinutes,
    super.checkInToken,
    super.paymentStatus,
    super.priorityLevel,
    super.statusUpdatedAt,
    super.checkedInAt,
    super.completedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json, String docId) {
    return AppointmentModel(
      id: docId,
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      specialty: json['specialty'] ?? '',
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      status: json['status'] ?? AppointmentStatuses.pendingBooking,
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      queueNumber: json['queueNumber'] as String?,
      estimatedWaitTimeMinutes: json['estimatedWaitTimeMinutes'] as int?,
      checkInToken: json['checkInToken'] as String?,
      paymentStatus: json['paymentStatus'] ?? AppointmentPaymentStatuses.unpaid,
      priorityLevel: json['priorityLevel'] ?? AppointmentPriorityLevels.normal,
      statusUpdatedAt: json['statusUpdatedAt'] != null
          ? (json['statusUpdatedAt'] as Timestamp).toDate()
          : null,
      checkedInAt: json['checkedInAt'] != null
          ? (json['checkedInAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': normalizedStatus,
      'notes': notes,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'queueNumber': queueNumber,
      'estimatedWaitTimeMinutes': estimatedWaitTimeMinutes,
      'checkInToken': checkInToken,
      'paymentStatus': paymentStatus,
      'priorityLevel': priorityLevel,
      'statusUpdatedAt': statusUpdatedAt != null
          ? Timestamp.fromDate(statusUpdatedAt!)
          : FieldValue.serverTimestamp(),
      'checkedInAt':
          checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum SlotStatus {
  available,
  reserved,
  booked,
}

class SlotEntity {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final SlotStatus status;
  final double? price;
  final String? patientId;

  SlotEntity({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.price,
    this.patientId,
  });

  factory SlotEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotEntity(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
      price: (data['price'] as num?)?.toDouble(),
      patientId: data['patientId'],
    );
  }

  static SlotStatus _parseStatus(String? status) {
    switch (status) {
      case 'reserved':
        return SlotStatus.reserved;
      case 'booked':
        return SlotStatus.booked;
      default:
        return SlotStatus.available;
    }
  }
}

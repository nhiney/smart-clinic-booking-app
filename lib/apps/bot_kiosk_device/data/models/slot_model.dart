import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/entities/slot_entity.dart';

class SlotModel extends SlotEntity {
  SlotModel({
    required super.id,
    required super.doctorId,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.price,
  });

  factory SlotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: _parseStatus(data['status']),
      price: (data['price'] as num?)?.toDouble(),
    );
  }

  static SlotStatus _parseStatus(String? status) {
    switch (status) {
      case 'available':
        return SlotStatus.available;
      case 'reserved':
        return SlotStatus.reserved;
      case 'booked':
        return SlotStatus.booked;
      default:
        return SlotStatus.available;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status.name,
      if (price != null) 'price': price,
    };
  }
}

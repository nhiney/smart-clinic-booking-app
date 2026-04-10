import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';

class SlotModel {
  final String slotId;
  final String doctorId;
  final DateTime date;
  final String timeSlot;
  final bool isBooked;
  final String? lockedBy;
  final DateTime? lockExpiresAt;
  final String? bookingId;

  const SlotModel({
    required this.slotId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    this.isBooked = false,
    this.lockedBy,
    this.lockExpiresAt,
    this.bookingId,
  });

  factory SlotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? {};
    final dateTs = m['date'];
    DateTime date = DateTime.now();
    if (dateTs is Timestamp) {
      date = dateTs.toDate();
    }
    final lockTs = m['lockExpiresAt'];
    DateTime? lockExp;
    if (lockTs is Timestamp) lockExp = lockTs.toDate();

    return SlotModel(
      slotId: doc.id,
      doctorId: (m['doctorId'] ?? '').toString(),
      date: date,
      timeSlot: (m['timeSlot'] ?? '').toString(),
      isBooked: m['isBooked'] == true,
      lockedBy: m['lockedBy']?.toString(),
      lockExpiresAt: lockExp,
      bookingId: m['bookingId']?.toString(),
    );
  }

  Map<String, dynamic> toFirestoreCreate({
    required String userId,
    required DateTime lockExpiresAt,
  }) {
    return {
      'slotId': slotId,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ),
      'timeSlot': timeSlot,
      'isBooked': false,
      'lockedBy': userId,
      'lockExpiresAt': Timestamp.fromDate(lockExpiresAt),
    };
  }

  static SlotAvailability toAvailability(SlotModel? model, String userId) {
    if (model == null || !model.isBooked && model.lockedBy == null) {
      return const SlotAvailability(kind: SlotAvailabilityKind.available);
    }
    final now = DateTime.now();
    if (model.isBooked) {
      return const SlotAvailability(kind: SlotAvailabilityKind.booked);
    }
    final lb = model.lockedBy;
    final le = model.lockExpiresAt;
    if (lb != null && le != null) {
      if (le.isBefore(now) || le.isAtSameMomentAs(now)) {
        return const SlotAvailability(kind: SlotAvailabilityKind.lockExpired);
      }
      if (lb == userId) {
        return SlotAvailability(
          kind: SlotAvailabilityKind.lockedBySelf,
          lockExpiresAt: le,
          lockedBy: lb,
        );
      }
      return SlotAvailability(
        kind: SlotAvailabilityKind.lockedByOther,
        lockExpiresAt: le,
        lockedBy: lb,
      );
    }
    return const SlotAvailability(kind: SlotAvailabilityKind.available);
  }
}

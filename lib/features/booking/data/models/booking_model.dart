import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.doctorId,
    required super.slotId,
    required super.type,
    required super.specialty,
    required super.symptoms,
    required super.date,
    required super.timeSlot,
    required super.status,
    required super.paymentStatus,
    required super.createdAt,
    required super.expiresAt,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? {};
    final dateTs = m['date'];
    DateTime date = DateTime.now();
    if (dateTs is Timestamp) date = dateTs.toDate();
    final createdTs = m['createdAt'];
    DateTime created = DateTime.now();
    if (createdTs is Timestamp) created = createdTs.toDate();
    final expTs = m['expiresAt'];
    DateTime expires = created.add(const Duration(hours: 24));
    if (expTs is Timestamp) expires = expTs.toDate();

    return BookingModel(
      id: doc.id,
      userId: (m['userId'] ?? '').toString(),
      doctorId: (m['doctorId'] ?? '').toString(),
      slotId: (m['slotId'] ?? doc.id).toString(),
      type: (m['type'] ?? MedicalBookingTypes.clinic).toString(),
      specialty: (m['specialty'] ?? '').toString(),
      symptoms: (m['symptoms'] ?? '').toString(),
      date: date,
      timeSlot: (m['timeSlot'] ?? '').toString(),
      status: (m['status'] ?? MedicalBookingStatuses.pending).toString(),
      paymentStatus:
          (m['paymentStatus'] ?? MedicalBookingPaymentStatuses.unpaid).toString(),
      createdAt: created,
      expiresAt: expires,
    );
  }

  Map<String, dynamic> toFirestoreCreate({
    required String bookingDocId,
    required String slotId,
  }) {
    return {
      'bookingId': bookingDocId,
      'userId': userId,
      'doctorId': doctorId,
      'slotId': slotId,
      'type': type,
      'specialty': specialty,
      'symptoms': symptoms,
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ),
      'timeSlot': timeSlot,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}

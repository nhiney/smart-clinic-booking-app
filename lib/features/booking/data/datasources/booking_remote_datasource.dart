import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../models/booking_model.dart';
import '../models/slot_model.dart';
import 'package:smart_clinic_booking/core/services/qr_token_service.dart';

/// Firestore persistence for `bookings`, `slots`, and `waitlist`.
class BookingRemoteDatasource {
  BookingRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration lockTtl = Duration(minutes: 5);

  static String sanitizeSegment(String s) {
    return s.replaceAll(RegExp(r'[/\\\s]'), '_');
  }

  static String buildSlotId(
    String doctorId,
    DateTime date,
    String timeSlot,
  ) {
    final d = DateTime(date.year, date.month, date.day);
    final ds =
        '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final t = timeSlot.trim().replaceAll(RegExp(r'[^\w\-:.]'), '_');
    return '${sanitizeSegment(doctorId)}_${ds}_$t';
  }

  DocumentReference<Map<String, dynamic>> _slotRef(String slotId) =>
      _firestore.collection('slots').doc(slotId);

  Timestamp _dateOnly(DateTime date) =>
      Timestamp.fromDate(DateTime(date.year, date.month, date.day));

  Future<Map<String, SlotAvailability>> checkSlotsAvailability({
    required String userId,
    required String doctorId,
    required DateTime date,
    required List<String> timeSlots,
  }) async {
    final out = <String, SlotAvailability>{};
    await Future.wait(timeSlots.map((slot) async {
      final id = buildSlotId(doctorId, date, slot);
      final snap = await _slotRef(id).get();
      if (!snap.exists) {
        out[slot] = const SlotAvailability(kind: SlotAvailabilityKind.available);
        return;
      }
      final model = SlotModel.fromFirestore(snap);
      out[slot] = SlotModel.toAvailability(model, userId);
    }));
    return out;
  }

  Future<void> lockSlot({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) async {
    final slotId = buildSlotId(doctorId, date, timeSlot);
    final slotRef = _slotRef(slotId);
    final now = DateTime.now();
    final lockUntil = now.add(lockTtl);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(slotRef);
      if (!snap.exists) {
        transaction.set(slotRef, {
          'slotId': slotId,
          'doctorId': doctorId,
          'date': _dateOnly(date),
          'timeSlot': timeSlot,
          'isBooked': false,
          'lockedBy': userId,
          'lockExpiresAt': Timestamp.fromDate(lockUntil),
        });
        return;
      }
      final m = snap.data()!;
      if (m['isBooked'] == true) {
        throw StateError('SLOT_BOOKED');
      }
      final lb = m['lockedBy']?.toString();
      final le = m['lockExpiresAt'];
      DateTime? lockExp;
      if (le is Timestamp) lockExp = le.toDate();

      if (lb != null &&
          lb != userId &&
          lockExp != null &&
          lockExp.isAfter(now)) {
        throw StateError('SLOT_LOCKED_BY_OTHER');
      }

      transaction.set(
        slotRef,
        {
          'slotId': slotId,
          'doctorId': doctorId,
          'date': _dateOnly(date),
          'timeSlot': timeSlot,
          'isBooked': false,
          'lockedBy': userId,
          'lockExpiresAt': Timestamp.fromDate(lockUntil),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> releaseSlotLock({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) async {
    final slotId = buildSlotId(doctorId, date, timeSlot);
    final slotRef = _slotRef(slotId);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(slotRef);
      if (!snap.exists) return;
      final m = snap.data()!;
      if (m['isBooked'] == true) return;
      if (m['lockedBy']?.toString() != userId) return;
      transaction.update(slotRef, {
        'lockedBy': FieldValue.delete(),
        'lockExpiresAt': FieldValue.delete(),
      });
    });
  }

  Future<BookingEntity> confirmBooking({
    required String userId,
    required String doctorId,
    required String type,
    required String specialty,
    required String symptoms,
    required DateTime date,
    required String timeSlot,
    required Duration bookingTtlUnpaid,
  }) async {
    final slotId = buildSlotId(doctorId, date, timeSlot);
    final slotRef = _slotRef(slotId);
    final bookingRef = _firestore.collection('bookings').doc();
    final now = DateTime.now();
    final expiresAt = now.add(bookingTtlUnpaid);

    // Parse timeSlot ("HH:mm") to compute appointment DateTime for QR window.
    DateTime appointmentTime;
    try {
      final parts = timeSlot.split(':');
      appointmentTime = DateTime(
        date.year, date.month, date.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
    } catch (_) {
      appointmentTime = DateTime(date.year, date.month, date.day, 8);
    }

    final qr = QrTokenService.generate(
      bookingId: bookingRef.id,
      userId: userId,
      appointmentTime: appointmentTime,
    );

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(slotRef);
      if (!snap.exists) {
        throw StateError('SLOT_LOCK_MISSING');
      }
      final m = snap.data()!;
      if (m['isBooked'] == true) {
        throw StateError('SLOT_BOOKED');
      }
      final lb = m['lockedBy']?.toString();
      final le = m['lockExpiresAt'];
      DateTime? lockExp;
      if (le is Timestamp) lockExp = le.toDate();
      if (lb != userId) {
        throw StateError('SLOT_NOT_YOUR_LOCK');
      }
      if (lockExp == null ||
          lockExp.isBefore(now) ||
          lockExp.isAtSameMomentAs(now)) {
        throw StateError('SLOT_LOCK_EXPIRED');
      }

      transaction.set(bookingRef, {
        'bookingId': bookingRef.id,
        'userId': userId,
        'doctorId': doctorId,
        'slotId': slotId,
        'type': type,
        'specialty': specialty,
        'symptoms': symptoms,
        'date': _dateOnly(date),
        'timeSlot': timeSlot,
        'status': MedicalBookingStatuses.pending,
        'paymentStatus': MedicalBookingPaymentStatuses.unpaid,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'checkInToken': qr.token,
        'qrValidFrom': Timestamp.fromDate(qr.nbf),
        'qrExpiresAt': Timestamp.fromDate(qr.exp),
      });

      transaction.set(
        slotRef,
        {
          'isBooked': true,
          'bookingId': bookingRef.id,
          'lockedBy': FieldValue.delete(),
          'lockExpiresAt': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
    });

    final fresh = await bookingRef.get();
    if (fresh.exists && fresh.data() != null) {
      return BookingModel.fromFirestore(fresh);
    }

    return BookingEntity(
      id: bookingRef.id,
      userId: userId,
      doctorId: doctorId,
      slotId: slotId,
      type: type,
      specialty: specialty,
      symptoms: symptoms,
      date: DateTime(date.year, date.month, date.day),
      timeSlot: timeSlot,
      status: MedicalBookingStatuses.pending,
      paymentStatus: MedicalBookingPaymentStatuses.unpaid,
      createdAt: now,
      expiresAt: expiresAt,
      checkInToken: qr.token,
      qrValidFrom: qr.nbf,
      qrExpiresAt: qr.exp,
    );
  }

  Future<void> joinWaitlist({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) async {
    await _firestore.collection('waitlist').add({
      'doctorId': doctorId,
      'date': _dateOnly(date),
      'timeSlot': timeSlot,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<BookingEntity> rescheduleBooking({
    required String bookingId,
    required String userId,
    required String doctorId,
    required DateTime newDate,
    required String newTimeSlot,
    required Duration bookingTtlUnpaid,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final newSlotId = buildSlotId(doctorId, newDate, newTimeSlot);
    final newSlotRef = _slotRef(newSlotId);
    final now = DateTime.now();
    final newExpires = now.add(bookingTtlUnpaid);

    await _firestore.runTransaction((tx) async {
      final bSnap = await tx.get(bookingRef);
      if (!bSnap.exists) throw StateError('BOOKING_NOT_FOUND');
      final bd = bSnap.data()!;
      if (bd['userId']?.toString() != userId) {
        throw StateError('NOT_OWNER');
      }

      final oldSlotId = bd['slotId']?.toString();
      if (oldSlotId == null || oldSlotId.isEmpty) {
        throw StateError('BOOKING_SLOT_UNKNOWN');
      }
      final oldSlotRef = _slotRef(oldSlotId);

      final newSnap = await tx.get(newSlotRef);
      if (newSnap.exists) {
        final nm = newSnap.data()!;
        if (nm['isBooked'] == true) {
          throw StateError('NEW_SLOT_BOOKED');
        }
        final lb = nm['lockedBy']?.toString();
        final le = nm['lockExpiresAt'];
        DateTime? lockExp;
        if (le is Timestamp) lockExp = le.toDate();
        if (lb != null &&
            lb != userId &&
            lockExp != null &&
            lockExp.isAfter(now)) {
          throw StateError('NEW_SLOT_LOCKED');
        }
      }

      final oldSnap = await tx.get(oldSlotRef);
      if (oldSnap.exists) {
        final om = oldSnap.data()!;
        if (om['bookingId']?.toString() == bookingId) {
          tx.set(
            oldSlotRef,
            {
              'isBooked': false,
              'bookingId': FieldValue.delete(),
              'lockedBy': FieldValue.delete(),
              'lockExpiresAt': FieldValue.delete(),
            },
            SetOptions(merge: true),
          );
        }
      }

      if (!newSnap.exists) {
        tx.set(newSlotRef, {
          'slotId': newSlotId,
          'doctorId': doctorId,
          'date': _dateOnly(newDate),
          'timeSlot': newTimeSlot,
          'isBooked': true,
          'bookingId': bookingId,
        });
      } else {
        tx.set(
          newSlotRef,
          {
            'isBooked': true,
            'bookingId': bookingId,
            'lockedBy': FieldValue.delete(),
            'lockExpiresAt': FieldValue.delete(),
          },
          SetOptions(merge: true),
        );
      }

      tx.update(bookingRef, {
        'slotId': newSlotId,
        'date': _dateOnly(newDate),
        'timeSlot': newTimeSlot,
        'status': MedicalBookingStatuses.pending,
        'expiresAt': Timestamp.fromDate(newExpires),
      });
    });

    final fresh = await bookingRef.get();
    return BookingModel.fromFirestore(fresh);
  }

  Future<int> expireStaleUnpaidBookings(String userId) async {
    final now = DateTime.now();
    final qs = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('paymentStatus',
            isEqualTo: MedicalBookingPaymentStatuses.unpaid)
        .limit(30)
        .get();

    var count = 0;
    for (final doc in qs.docs) {
      final m = doc.data();
      final status = m['status']?.toString() ?? '';
      if (!MedicalBookingStatuses.isActive(status)) continue;
      final exp = m['expiresAt'];
      if (exp is! Timestamp) continue;
      if (exp.toDate().isAfter(now)) continue;

      try {
        await _firestore.runTransaction((tx) async {
          final snap = await tx.get(doc.reference);
          if (!snap.exists) return;
          final d = snap.data()!;
          if (d['paymentStatus']?.toString() !=
              MedicalBookingPaymentStatuses.unpaid) {
            return;
          }
          final e = d['expiresAt'];
          if (e is! Timestamp || e.toDate().isAfter(now)) return;

          final slotId = d['slotId']?.toString();
          tx.update(doc.reference, {
            'status': MedicalBookingStatuses.cancelled,
          });

          if (slotId != null && slotId.isNotEmpty) {
            final sr = _slotRef(slotId);
            final ss = await tx.get(sr);
            if (ss.exists) {
              final sm = ss.data()!;
              if (sm['bookingId']?.toString() == doc.id) {
                tx.set(
                  sr,
                  {
                    'isBooked': false,
                    'bookingId': FieldValue.delete(),
                    'lockedBy': FieldValue.delete(),
                    'lockExpiresAt': FieldValue.delete(),
                  },
                  SetOptions(merge: true),
                );
              }
            }
          }
        });
        count++;
      } catch (_) {
        // concurrent update; skip
      }
    }
    return count;
  }
}

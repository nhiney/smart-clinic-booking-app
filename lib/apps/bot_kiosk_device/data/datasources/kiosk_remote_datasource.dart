import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/core/errors/kiosk_exceptions.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/data/models/slot_model.dart';

abstract class IKioskRemoteDataSource {
  Future<void> reserveSlot(String slotId, String patientId);
  Future<List<SlotModel>> getAvailableSlots(String doctorId, DateTime date);
}

class KioskRemoteDataSourceImpl implements IKioskRemoteDataSource {
  final FirebaseFirestore _firestore;

  KioskRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> reserveSlot(String slotId, String patientId) async {
    return await _firestore.runTransaction((transaction) async {
      final slotRef = _firestore.collection('slots').doc(slotId);
      final slotSnapshot = await transaction.get(slotRef);

      if (!slotSnapshot.exists) {
        throw Exception('Giờ khám không tồn tại.');
      }

      final data = slotSnapshot.data()!;
      if (data['status'] != 'available') {
        throw SlotAlreadyBookedException();
      }

      // Thực hiện đặt chỗ
      transaction.update(slotRef, {
        'status': 'booked',
        'patientId': patientId,
        'reservedAt': FieldValue.serverTimestamp(),
        'bookedBy': 'kiosk_device',
      });
      
      // Tạo một document booking tương ứng
      final bookingRef = _firestore.collection('bookings').doc();
      transaction.set(bookingRef, {
        'slotId': slotId,
        'patientId': patientId,
        'doctorId': data['doctorId'],
        'appointmentTime': data['startTime'],
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'kiosk',
      });
    });
  }

  @override
  Future<List<SlotModel>> getAvailableSlots(String doctorId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('slots')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'available')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return querySnapshot.docs.map((doc) => SlotModel.fromFirestore(doc)).toList();
  }
}

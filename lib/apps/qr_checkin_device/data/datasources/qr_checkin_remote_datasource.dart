import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/core/errors/qr_exceptions.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/data/models/check_in_result_model.dart';

abstract class IQRCheckInRemoteDataSource {
  Future<CheckInResultModel> processCheckIn(String bookingId);
}

class QRCheckInRemoteDataSourceImpl implements IQRCheckInRemoteDataSource {
  final FirebaseFirestore _firestore;

  QRCheckInRemoteDataSourceImpl(this._firestore);

  @override
  Future<CheckInResultModel> processCheckIn(String bookingId) async {
    return await _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw InvalidQRCodeException();
      }

      final data = bookingSnapshot.data()!;
      
      // 1. Kiểm tra trạng thái
      if (data['status'] == 'checked_in') {
        throw AlreadyCheckedInException();
      }
      
      if (data['status'] == 'cancelled') {
        throw InvalidQRCodeException(); // Lịch hẹn đã bị hủy
      }

      // 2. Kiểm tra thời gian (Không sớm quá 60 phút)
      final appointmentTime = (data['appointmentTime'] as Timestamp).toDate();
      final now = DateTime.now();
      final difference = appointmentTime.difference(now).inMinutes;

      if (difference > 60) {
        throw TooEarlyException();
      }

      // 3. Lấy số thứ tự khám tiếp theo cho bác sĩ trong ngày hôm nay
      // Giả sử có một collection 'queue_counters' để quản lý số thứ tự
      final doctorId = data['doctorId'];
      final dateId = '${now.year}-${now.month}-${now.day}';
      final counterRef = _firestore
          .collection('queue_counters')
          .doc('${doctorId}_$dateId');
      
      final counterSnapshot = await transaction.get(counterRef);
      int nextQueueNumber = 1;
      
      if (counterSnapshot.exists) {
        nextQueueNumber = (counterSnapshot.data()!['current'] as int) + 1;
        transaction.update(counterRef, {'current': nextQueueNumber});
      } else {
        transaction.set(counterRef, {'current': 1, 'doctorId': doctorId, 'date': now});
      }

      // 4. Cập nhật booking
      transaction.update(bookingRef, {
        'status': 'checked_in',
        'checkInTime': FieldValue.serverTimestamp(),
        'queueNumber': nextQueueNumber,
      });

      // Lấy thêm thông tin để hiển thị kết quả
      final patientName = data['patientName'] ?? 'Bệnh nhân';
      final doctorName = data['doctorName'] ?? 'Bác sĩ';

      return CheckInResultModel(
        bookingId: bookingId,
        patientName: patientName,
        doctorName: doctorName,
        queueNumber: nextQueueNumber.toString(),
        checkInTime: now,
      );
    });
  }
}

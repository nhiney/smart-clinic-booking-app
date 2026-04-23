import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/check_in_model.dart'; // I will create this model next
import '../../domain/exceptions/qr_checkin_exceptions.dart';

class QrKioskRemoteDataSource {
  final FirebaseFirestore _firestore;

  QrKioskRemoteDataSource(this._firestore);

  Future<CheckInModel> runCheckInTransaction(String appointmentId) async {
    return _firestore.runTransaction((transaction) async {
      final docRef = _firestore.collection('appointments').doc(appointmentId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw InvalidQRCodeException();
      }

      final data = snapshot.data()!;
      final status = data['status'] as String?;

      if (status == 'checked_in') {
        throw AlreadyCheckedInException();
      }

      // Update status to checked_in
      transaction.update(docRef, {
        'status': 'checked_in',
        'checkInTime': FieldValue.serverTimestamp(),
      });

      // Prepare model data
      return CheckInModel.fromFirestore(snapshot);
    });
  }
}

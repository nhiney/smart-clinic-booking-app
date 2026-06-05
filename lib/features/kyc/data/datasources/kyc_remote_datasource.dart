import 'package:cloud_firestore/cloud_firestore.dart';

class KycRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitApplication(Map<String, dynamic> data) async {
    await _firestore.collection('doctor_applications').add({
      ...data,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingApplications(String tenantId) async {
    final snapshot = await _firestore
        .collection('doctor_applications')
        .where('tenantId', isEqualTo: tenantId)
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> approveDoctor(String doctorUid, String targetTenantId) async {
    final snapshot = await _firestore
        .collection('doctor_applications')
        .where('doctorUid', isEqualTo: doctorUid)
        .where('tenantId', isEqualTo: targetTenantId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw StateError('Không tìm thấy hồ sơ cho doctorUid: $doctorUid');
    }

    await snapshot.docs.first.reference.update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }
}

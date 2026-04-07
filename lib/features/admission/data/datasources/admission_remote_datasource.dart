import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admission_model.dart';

class AdmissionRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AdmissionModel>> getAdmissionsByPatient(String patientId) async {
    final snapshot = await _firestore
        .collection('admissions')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AdmissionModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<String> createAdmissionRequest(AdmissionModel admission) async {
    final docRef = await _firestore.collection('admissions').add(admission.toJson());
    return docRef.id;
  }

  Future<void> updateStatus(String docId, String status) async {
    await _firestore.collection('admissions').doc(docId).update({
      'status': status,
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_record_model.dart';

class MedicalRecordRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MedicalRecordModel>> getRecordsByPatient(String patientId) async {
    final snapshot = await _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => MedicalRecordModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<MedicalRecordModel?> getRecordById(String id) async {
    final doc = await _firestore.collection('medical_records').doc(id).get();
    if (!doc.exists) return null;
    return MedicalRecordModel.fromJson(doc.data()!, doc.id);
  }
}

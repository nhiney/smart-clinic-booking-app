import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/admission_model.dart';

class AdmissionRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<AdmissionModel>> getAdmissionsByPatient(String patientId) async {
    final snapshot = await _firestore
        .collection('admissions')
        .where('patientId', isEqualTo: patientId)
        .get();

    final list = snapshot.docs
        .map((doc) => AdmissionModel.fromJson(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<AdmissionModel?> getAdmission(String admissionId) async {
    final doc = await _firestore.collection('admissions').doc(admissionId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AdmissionModel.fromJson(doc.data()!, doc.id);
  }

  Stream<AdmissionModel?> watchAdmission(String admissionId) {
    return _firestore.collection('admissions').doc(admissionId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AdmissionModel.fromJson(doc.data()!, doc.id);
    });
  }

  Stream<List<AdmissionModel>> watchAdmissionsByPatient(String patientId) {
    return _firestore
        .collection('admissions')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AdmissionModel.fromJson(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<String> createAdmissionRequest(AdmissionModel admission) async {
    final docRef = await _firestore.collection('admissions').add(admission.toJson());
    return docRef.id;
  }

  Future<void> updateStatus(String docId, String status, {Map<String, dynamic>? extra}) async {
    final data = <String, dynamic>{'status': status, ...?extra};
    await _firestore.collection('admissions').doc(docId).update(data);
  }

  Future<void> updateAdmission(String docId, Map<String, dynamic> data) async {
    await _firestore.collection('admissions').doc(docId).update(data);
  }

  Future<String> uploadDocument(String admissionId, String patientId, File file, String fileName) async {
    final ext = fileName.split('.').last;
    final path = 'admissions/$patientId/$admissionId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> addDocumentUrl(String admissionId, String url) async {
    await _firestore.collection('admissions').doc(admissionId).update({
      'documentUrls': FieldValue.arrayUnion([url]),
    });
  }

  Future<void> removeDocumentUrl(String admissionId, String url) async {
    await _firestore.collection('admissions').doc(admissionId).update({
      'documentUrls': FieldValue.arrayRemove([url]),
    });
  }
}

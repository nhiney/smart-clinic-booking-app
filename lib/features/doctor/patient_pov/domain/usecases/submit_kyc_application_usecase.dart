import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitKYCApplicationUseCase {
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SubmitKYCApplicationUseCase({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> execute({
    required File idCardFile,
    required File medicalDegreeFile,
    required String targetHospitalId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Unauthorized to upload KYC");

    // Upload to secured Cloud Storage bucket using user ID boundary
    final idRef = _storage.ref().child('kyc_documents/${user.uid}/id_card.pdf');
    final degreeRef = _storage.ref().child('kyc_documents/${user.uid}/medical_degree.pdf');

    await idRef.putFile(idCardFile);
    await degreeRef.putFile(medicalDegreeFile);

    // Retrieve secure download URLs for the application document
    final idUrl = await idRef.getDownloadURL();
    final degreeUrl = await degreeRef.getDownloadURL();

    // Create doctor application document. 
    // Status is maintained securely as 'pending'.
    await _firestore.collection('doctor_applications').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'targetHospitalId': targetHospitalId,
      'idCardStorageUrl': idUrl, 
      'medicalDegreeStorageUrl': degreeUrl,
      'status': 'pending', 
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}

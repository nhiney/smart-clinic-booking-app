import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medical_record_model.dart';
import '../models/attachment_model.dart';

abstract class IMedicalRecordRemoteDataSource {
  Future<List<MedicalRecordModel>> getRecords(String patientId);
  Future<void> uploadAttachment({
    required File file,
    required String recordId,
    required String patientId,
    required String fileName,
  });
}

class MedicalRecordRemoteDataSourceImpl implements IMedicalRecordRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  MedicalRecordRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<MedicalRecordModel>> getRecords(String patientId) async {
    try {
      final snapshot = await firestore
          .collection('patients')
          .doc(patientId)
          .collection('medical_records')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicalRecordModel.fromSnapshot(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> uploadAttachment({
    required File file,
    required String recordId,
    required String patientId,
    required String fileName,
  }) async {
    try {
      // 1. Storage Reference: Resumable Path
      final storageRef = storage
          .ref()
          .child('medical_records')
          .child(patientId)
          .child(recordId)
          .child(fileName);

      // 2. PutFile with UploadTask (Supports resuming and progress tracking)
      final uploadTask = storageRef.putFile(file);

      // We await the completion of the task in the data source itself for the unit result
      final TaskSnapshot snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Update Firestore Root Document (Latest state)
      final attachment = AttachmentModel(
        id: firestore.collection('dummy').doc().id,
        name: fileName,
        downloadUrl: downloadUrl,
        fileType: fileName.split('.').last,
        uploadedAt: DateTime.now(),
      );

      await firestore
          .collection('patients')
          .doc(patientId)
          .collection('medical_records')
          .doc(recordId)
          .update({
        'attachments': FieldValue.arrayUnion([attachment.toJson()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

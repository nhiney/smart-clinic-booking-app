import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/encounter_fhir.dart';
import '../../domain/entities/observation_fhir.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/record_version.dart';
import '../../domain/entities/record_share.dart';
import '../../domain/entities/medical_record_entity.dart';

abstract class MedicalRecordRemoteDataSource {
  Future<List<EncounterFhir>> getEncounters(String patientId);
  Future<void> createEncounter(EncounterFhir encounter);
  Future<List<ObservationFhir>> getObservations(String encounterId);

  // File attachments
  Stream<TaskSnapshot> uploadAttachment({
    required String recordId,
    required String patientId,
    required File file,
    required String fileName,
  });
  Future<List<Attachment>> getAttachments(String recordId);
  Future<void> deleteAttachment(String recordId, String attachmentId, String storagePath);

  // Versioning
  Future<void> createVersion(String recordId, MedicalRecordEntity record, {String changeNote = ''});
  Future<List<RecordVersion>> getVersions(String recordId);

  // Sharing
  Future<RecordShare> shareRecord({
    required String recordId,
    required String ownerId,
    required String sharedWithId,
    required SharePermission permission,
    DateTime? expiresAt,
  });
  Future<List<RecordShare>> getSharedByMe(String ownerId);
  Future<List<RecordShare>> getSharedWithMe(String userId);
  Future<void> revokeShare(String shareId);
}

class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final _uuid = const Uuid();

  MedicalRecordRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  // ─── FHIR ────────────────────────────────────────────────────────────────

  @override
  Future<List<EncounterFhir>> getEncounters(String patientId) async {
    final snapshot = await firestore
        .collection('encounters')
        .where('subject.reference', isEqualTo: 'Patient/$patientId')
        .orderBy('period.start', descending: true)
        .get();
    return snapshot.docs.map((doc) => EncounterFhir.fromJson(doc.data())).toList();
  }

  @override
  Future<void> createEncounter(EncounterFhir encounter) async {
    await firestore.collection('encounters').doc(encounter.id).set(encounter.toJson());
  }

  @override
  Future<List<ObservationFhir>> getObservations(String encounterId) async {
    final snapshot = await firestore
        .collection('observations')
        .where('encounter.reference', isEqualTo: 'Encounter/$encounterId')
        .get();
    return snapshot.docs.map((doc) => ObservationFhir.fromJson(doc.data())).toList();
  }

  // ─── ATTACHMENTS ─────────────────────────────────────────────────────────

  @override
  Stream<TaskSnapshot> uploadAttachment({
    required String recordId,
    required String patientId,
    required File file,
    required String fileName,
  }) {
    final attachmentId = _uuid.v4();
    final ext = fileName.contains('.') ? fileName.split('.').last : 'bin';
    final storagePath = 'medical_records/$patientId/$recordId/${attachmentId}_$fileName';
    final ref = storage.ref(storagePath);

    final mimeType = _mimeFromExt(ext);
    final uploadTask = ref.putFile(file, SettableMetadata(contentType: mimeType));

    // Register attachment metadata in Firestore when done
    uploadTask.snapshotEvents.listen((snapshot) async {
      if (snapshot.state == TaskState.success) {
        final url = await ref.getDownloadURL();
        final fileSize = await file.length();
        final attachment = {
          'id': attachmentId,
          'name': fileName,
          'downloadUrl': url,
          'storagePath': storagePath,
          'fileType': ext.toUpperCase(),
          'mimeType': mimeType,
          'fileSize': fileSize,
          'uploadedAt': FieldValue.serverTimestamp(),
        };
        await firestore
            .collection('medical_records')
            .doc(recordId)
            .collection('attachments')
            .doc(attachmentId)
            .set(attachment);
      }
    });

    return uploadTask.snapshotEvents;
  }

  @override
  Future<List<Attachment>> getAttachments(String recordId) async {
    final snapshot = await firestore
        .collection('medical_records')
        .doc(recordId)
        .collection('attachments')
        .orderBy('uploadedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Attachment(
        id: data['id'] as String,
        name: data['name'] as String,
        downloadUrl: data['downloadUrl'] as String,
        fileType: data['fileType'] as String,
        uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> deleteAttachment(String recordId, String attachmentId, String storagePath) async {
    await storage.ref(storagePath).delete();
    await firestore
        .collection('medical_records')
        .doc(recordId)
        .collection('attachments')
        .doc(attachmentId)
        .delete();
  }

  // ─── VERSIONING ───────────────────────────────────────────────────────────

  @override
  Future<void> createVersion(String recordId, MedicalRecordEntity record, {String changeNote = ''}) async {
    final versionsRef = firestore
        .collection('medical_records')
        .doc(recordId)
        .collection('versions');

    final count = (await versionsRef.count().get()).count ?? 0;

    await versionsRef.add({
      'id': _uuid.v4(),
      'recordId': recordId,
      'versionNumber': count + 1,
      'changedBy': record.userId,
      'changeNote': changeNote,
      'snapshot': {
        'doctor': record.doctor,
        'diagnosis': record.diagnosis,
        'prescription': record.prescription,
        'symptoms': record.symptoms,
        'notes': record.notes,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<RecordVersion>> getVersions(String recordId) async {
    final snapshot = await firestore
        .collection('medical_records')
        .doc(recordId)
        .collection('versions')
        .orderBy('versionNumber', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RecordVersion.fromJson(data);
    }).toList();
  }

  // ─── SHARING ─────────────────────────────────────────────────────────────

  @override
  Future<RecordShare> shareRecord({
    required String recordId,
    required String ownerId,
    required String sharedWithId,
    required SharePermission permission,
    DateTime? expiresAt,
  }) async {
    final shareId = _uuid.v4();
    final data = {
      'id': shareId,
      'recordId': recordId,
      'ownerId': ownerId,
      'sharedWithId': sharedWithId,
      'permission': permission.name,
      'sharedAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      'isRevoked': false,
    };
    await firestore.collection('record_shares').doc(shareId).set(data);
    return RecordShare(
      id: shareId,
      recordId: recordId,
      ownerId: ownerId,
      sharedWithId: sharedWithId,
      permission: permission,
      sharedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
  }

  @override
  Future<List<RecordShare>> getSharedByMe(String ownerId) async {
    final snapshot = await firestore
        .collection('record_shares')
        .where('ownerId', isEqualTo: ownerId)
        .where('isRevoked', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RecordShare.fromJson(data);
    }).toList();
  }

  @override
  Future<List<RecordShare>> getSharedWithMe(String userId) async {
    final snapshot = await firestore
        .collection('record_shares')
        .where('sharedWithId', isEqualTo: userId)
        .where('isRevoked', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RecordShare.fromJson(data);
    }).toList();
  }

  @override
  Future<void> revokeShare(String shareId) async {
    await firestore.collection('record_shares').doc(shareId).update({'isRevoked': true});
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  String _mimeFromExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'dcm':
        return 'application/dicom';
      default:
        return 'application/octet-stream';
    }
  }
}

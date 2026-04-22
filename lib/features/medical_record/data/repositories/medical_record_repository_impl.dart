import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/encounter_fhir.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/attachment.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/record_version.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/record_share.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/repositories/medical_record_repository.dart';
import 'package:smart_clinic_booking/features/medical_record/data/models/medical_record_model.dart';
import 'package:smart_clinic_booking/features/medical_record/data/datasources/medical_record_remote_datasource.dart';
import 'package:smart_clinic_booking/features/medical_record/data/datasources/medical_record_local_datasource.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDataSource remoteDataSource;
  final MedicalRecordLocalDataSource localDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SQLiteHelper _sqlite = SQLiteHelper.instance;

  MedicalRecordRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ─── RECORDS ─────────────────────────────────────────────────────────────

  @override
  Future<List<MedicalRecordEntity>> getMedicalRecords(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('medical_records')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final records = snapshot.docs.map((doc) => MedicalRecordModel.fromFirestore(doc)).toList();

      final db = await _sqlite.database;
      await db.transaction((txn) async {
        for (final r in records) {
          await txn.insert(
            'medical_records_cache',
            {
              'id': r.id,
              'userId': r.userId,
              'data': jsonEncode(r.toFirestore()..['createdAt'] = r.createdAt.toIso8601String()),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return records;
    } catch (_) {
      final db = await _sqlite.database;
      final maps = await db.query('medical_records_cache', where: 'userId = ?', whereArgs: [userId]);
      return maps.map((m) {
        final data = jsonDecode(m['data'] as String) as Map<String, dynamic>;
        return MedicalRecordModel(
          id: m['id'] as String,
          userId: m['userId'] as String,
          doctor: data['doctor'] as String? ?? '',
          diagnosis: data['diagnosis'] as String? ?? '',
          prescription: data['prescription'] as String? ?? '',
          createdAt: DateTime.parse(data['createdAt'] as String),
          symptoms: (data['symptoms'] as List?)?.map((e) => e.toString()).toList(),
          notes: data['notes'] as String?,
        );
      }).toList();
    }
  }

  @override
  Future<void> addMedicalRecord(MedicalRecordEntity record) async {
    final model = MedicalRecordModel(
      id: record.id,
      userId: record.userId,
      doctor: record.doctor,
      diagnosis: record.diagnosis,
      prescription: record.prescription,
      createdAt: record.createdAt,
      symptoms: record.symptoms,
      notes: record.notes,
    );
    await _firestore.collection('medical_records').doc(record.id).set(model.toFirestore());
    final db = await _sqlite.database;
    await db.insert(
      'medical_records_cache',
      {
        'id': record.id,
        'userId': record.userId,
        'data': jsonEncode(model.toFirestore()..['createdAt'] = record.createdAt.toIso8601String()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Create initial version snapshot
    await createVersion(record.id, record, changeNote: 'Initial version');
  }

  @override
  Future<Either<Failure, List<EncounterFhir>>> getMedicalHistory(String patientId) async {
    try {
      final encounters = await remoteDataSource.getEncounters(patientId);
      return Right(encounters);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ─── ATTACHMENTS ─────────────────────────────────────────────────────────

  @override
  Stream<TaskSnapshot> uploadAttachment({
    required String recordId,
    required String patientId,
    required File file,
    required String fileName,
  }) {
    return remoteDataSource.uploadAttachment(
      recordId: recordId,
      patientId: patientId,
      file: file,
      fileName: fileName,
    );
  }

  @override
  Future<List<Attachment>> getAttachments(String recordId) {
    return remoteDataSource.getAttachments(recordId);
  }

  @override
  Future<void> deleteAttachment(String recordId, String attachmentId, String storagePath) {
    return remoteDataSource.deleteAttachment(recordId, attachmentId, storagePath);
  }

  // ─── VERSIONING ───────────────────────────────────────────────────────────

  @override
  Future<void> createVersion(String recordId, MedicalRecordEntity record, {String changeNote = ''}) {
    return remoteDataSource.createVersion(recordId, record, changeNote: changeNote);
  }

  @override
  Future<List<RecordVersion>> getVersions(String recordId) {
    return remoteDataSource.getVersions(recordId);
  }

  // ─── SHARING ─────────────────────────────────────────────────────────────

  @override
  Future<RecordShare> shareRecord({
    required String recordId,
    required String ownerId,
    required String sharedWithId,
    required SharePermission permission,
    DateTime? expiresAt,
  }) {
    return remoteDataSource.shareRecord(
      recordId: recordId,
      ownerId: ownerId,
      sharedWithId: sharedWithId,
      permission: permission,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<List<RecordShare>> getSharedByMe(String ownerId) {
    return remoteDataSource.getSharedByMe(ownerId);
  }

  @override
  Future<List<RecordShare>> getSharedWithMe(String userId) {
    return remoteDataSource.getSharedWithMe(userId);
  }

  @override
  Future<void> revokeShare(String shareId) {
    return remoteDataSource.revokeShare(shareId);
  }
}

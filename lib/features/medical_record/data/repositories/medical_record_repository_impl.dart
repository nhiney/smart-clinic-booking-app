import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/encounter_fhir.dart';
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

  @override
  Future<List<MedicalRecordEntity>> getMedicalRecords(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('medical_records')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final records = snapshot.docs.map((doc) => MedicalRecordModel.fromFirestore(doc)).toList();
      
      // Cache to SQLite
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
    } catch (e) {
      // Fallback to SQLite
      final db = await _sqlite.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medical_records_cache',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      return maps.map((m) {
        final data = jsonDecode(m['data']);
        return MedicalRecordModel(
          id: m['id'],
          userId: m['userId'],
          doctor: data['doctor'] ?? '',
          diagnosis: data['diagnosis'] ?? '',
          prescription: data['prescription'] ?? '',
          createdAt: DateTime.parse(data['createdAt']),
          symptoms: (data['symptoms'] as List?)?.map((e) => e.toString()).toList(),
          notes: data['notes'],
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
    
    // Save to Firestore
    await _firestore.collection('medical_records').doc(record.id).set(model.toFirestore());
    
    // Cache to SQLite
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
}

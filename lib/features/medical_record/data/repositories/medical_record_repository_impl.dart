import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/encounter_fhir.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/repositories/medical_record_repository.dart';
import 'package:smart_clinic_booking/features/medical_record/data/models/medical_record_model.dart';
import 'package:smart_clinic_booking/features/medical_record/data/datasources/medical_record_remote_datasource.dart';
import 'package:smart_clinic_booking/features/medical_record/data/datasources/medical_record_local_datasource.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDataSource remoteDataSource;
  final MedicalRecordLocalDataSource localDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MedicalRecordRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<MedicalRecordEntity>> getMedicalRecords(String userId) async {
    final snapshot = await _firestore
        .collection('medical_records')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => MedicalRecordModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addMedicalRecord(MedicalRecordEntity record) async {
    final model = MedicalRecordModel(
      id: record.id,
      userId: record.userId,
      doctor: record.doctor,
      diagnosis: record.diagnosis,
      prescription: record.prescription,
      date: record.date,
      symptoms: record.symptoms,
      notes: record.notes,
    );
    await _firestore.collection('medical_records').add(model.toFirestore());
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

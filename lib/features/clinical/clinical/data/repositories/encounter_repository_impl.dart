import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinical_encounter.dart';
import '../../domain/entities/medication_plan_item.dart';
import '../../domain/repositories/encounter_repository.dart';
import '../datasources/clinical_mock_datasource.dart';

class EncounterRepositoryImpl implements EncounterRepository {
  final ClinicalMockDataSource dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EncounterRepositoryImpl(this.dataSource);

  @override
  Future<ClinicalEncounter> getEncounter(String encounterId) async {
    final docRef = _firestore.collection('encounters').doc(encounterId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Seed dynamically to Firestore if not exists
      final mock = dataSource.getEncounter(encounterId);
      await docRef.set(_mapToMap(mock));
      return mock;
    }

    final data = doc.data()!;
    return _mapToEncounter(encounterId, data);
  }

  @override
  Future<ClinicalEncounter> saveDraft(ClinicalEncounter encounter) async {
    final updated = encounter.copyWith(updatedAt: DateTime.now());
    await _firestore.collection('encounters').doc(encounter.id).set(_mapToMap(updated));
    return updated;
  }

  @override
  Future<ClinicalEncounter> completeEncounter(ClinicalEncounter encounter) async {
    final completed = encounter.copyWith(
      completed: true,
      updatedAt: DateTime.now(),
    );
    await _firestore.collection('encounters').doc(encounter.id).set(_mapToMap(completed));
    return completed;
  }

  Map<String, dynamic> _mapToMap(ClinicalEncounter enc) {
    return {
      'patientId': enc.patientId,
      'patientName': enc.patientName,
      'patientCode': enc.patientCode,
      'age': enc.age,
      'gender': enc.gender,
      'diagnosisBadge': enc.diagnosisBadge,
      'visitTimeLabel': enc.visitTimeLabel,
      'visitCount': enc.visitCount,
      'subjective': enc.subjective,
      'objective': enc.objective,
      'assessment': enc.assessment,
      'icdCodes': enc.icdCodes,
      'medications': enc.medications.map((m) => {
        'name': m.name,
        'dosage': m.dosage,
        'timesPerDay': m.timesPerDay,
        'days': m.days,
        'notes': m.notes,
      }).toList(),
      'labTests': enc.labTests,
      'imagingTests': enc.imagingTests,
      'followUpDate': enc.followUpDate != null ? Timestamp.fromDate(enc.followUpDate!) : null,
      'notes': enc.notes,
      'completed': enc.completed,
      'startedAt': Timestamp.fromDate(enc.startedAt),
      'updatedAt': Timestamp.fromDate(enc.updatedAt),
    };
  }

  ClinicalEncounter _mapToEncounter(String id, Map<String, dynamic> data) {
    final medsRaw = data['medications'] as List<dynamic>? ?? const [];
    final medications = medsRaw.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return MedicationPlanItem(
        name: map['name'] ?? '',
        dosage: map['dosage'] ?? '',
        timesPerDay: map['timesPerDay'] ?? 1,
        days: map['days'] ?? 7,
        notes: map['notes'] ?? '',
      );
    }).toList();

    return ClinicalEncounter(
      id: id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientCode: data['patientCode'] ?? '',
      age: data['age'] ?? 54,
      gender: data['gender'] ?? 'Nam',
      diagnosisBadge: data['diagnosisBadge'] ?? '',
      visitTimeLabel: data['visitTimeLabel'] ?? '',
      visitCount: data['visitCount'] ?? 1,
      subjective: data['subjective'] ?? '',
      objective: data['objective'] ?? '',
      assessment: data['assessment'] ?? '',
      icdCodes: List<String>.from(data['icdCodes'] ?? const []),
      medications: medications,
      labTests: List<String>.from(data['labTests'] ?? const []),
      imagingTests: List<String>.from(data['imagingTests'] ?? const []),
      followUpDate: data['followUpDate'] != null ? (data['followUpDate'] as Timestamp).toDate() : null,
      notes: data['notes'] ?? '',
      completed: data['completed'] ?? false,
      startedAt: data['startedAt'] != null ? (data['startedAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

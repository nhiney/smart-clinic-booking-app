import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/encounter_fhir.dart';
import '../../domain/entities/observation_fhir.dart';

abstract class MedicalRecordRemoteDataSource {
  Future<List<EncounterFhir>> getEncounters(String patientId);
  Future<void> createEncounter(EncounterFhir encounter);
  Future<List<ObservationFhir>> getObservations(String encounterId);
}

class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final FirebaseFirestore firestore;

  MedicalRecordRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<EncounterFhir>> getEncounters(String patientId) async {
    final snapshot = await firestore
        .collection('encounters')
        .where('subject.reference', isEqualTo: 'Patient/$patientId')
        .orderBy('period.start', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EncounterFhir.fromJson(doc.data()))
        .toList();
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

    return snapshot.docs
        .map((doc) => ObservationFhir.fromJson(doc.data()))
        .toList();
  }
}

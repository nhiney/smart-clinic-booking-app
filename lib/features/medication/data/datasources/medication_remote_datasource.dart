import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MedicationModel>> getMedicationsByPatient(String patientId) async {
    final snapshot = await _firestore
        .collection('medications')
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs
        .map((doc) => MedicationModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<MedicationModel> addMedication(MedicationModel medication) async {
    final docRef = await _firestore
        .collection('medications')
        .add(medication.toJson());
    return MedicationModel(
      id: docRef.id,
      patientId: medication.patientId,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      time: medication.time,
      startDate: medication.startDate,
      endDate: medication.endDate,
      isActive: medication.isActive,
      notes: medication.notes,
    );
  }

  Future<void> deleteMedication(String id) async {
    await _firestore.collection('medications').doc(id).delete();
  }

  Future<void> toggleMedication(String id, bool isActive) async {
    await _firestore
        .collection('medications')
        .doc(id)
        .update({'isActive': isActive});
  }
}

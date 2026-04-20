import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/medication_model.dart';
import '../../domain/entities/medication_intake.dart';

class MedicationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<MedicationModel>> getMedicationsByPatient(String patientId) async {
    final snapshot = await _firestore
        .collection('medications')
        .where('patientId', isEqualTo: patientId)
        .get();
    return snapshot.docs.map((doc) => MedicationModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<MedicationModel> addMedication(MedicationModel medication) async {
    final docRef = await _firestore.collection('medications').add(medication.toJson());
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
    await _firestore.collection('medications').doc(id).update({'isActive': isActive});
  }

  // ─── INTAKE TRACKING ─────────────────────────────────────────────────────

  Future<MedicationIntake> recordIntake({
    required String medicationId,
    required String patientId,
    required DateTime scheduledAt,
    required bool wasTaken,
    String? note,
  }) async {
    final intake = MedicationIntake(
      id: _uuid.v4(),
      medicationId: medicationId,
      patientId: patientId,
      scheduledAt: scheduledAt,
      takenAt: wasTaken ? DateTime.now() : null,
      wasTaken: wasTaken,
      note: note,
    );
    await _firestore
        .collection('medications')
        .doc(medicationId)
        .collection('intakes')
        .doc(intake.id)
        .set(intake.toJson());
    return intake;
  }

  Future<List<MedicationIntake>> getIntakes({
    required String medicationId,
    required DateTime from,
    required DateTime to,
  }) async {
    final snapshot = await _firestore
        .collection('medications')
        .doc(medicationId)
        .collection('intakes')
        .where('scheduledAt', isGreaterThanOrEqualTo: from.toIso8601String())
        .where('scheduledAt', isLessThanOrEqualTo: to.toIso8601String())
        .orderBy('scheduledAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => MedicationIntake.fromJson(doc.data())).toList();
  }

  /// Returns adherence rate [0.0, 1.0] for given medication over last [days].
  Future<double> getAdherenceRate(String medicationId, {int days = 30}) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    final intakes = await getIntakes(medicationId: medicationId, from: from, to: to);
    if (intakes.isEmpty) return 0;
    final taken = intakes.where((i) => i.wasTaken).length;
    return taken / intakes.length;
  }
}

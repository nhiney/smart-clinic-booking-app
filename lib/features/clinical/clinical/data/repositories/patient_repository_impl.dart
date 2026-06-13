import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/clinical_mock_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final ClinicalMockDataSource dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PatientRepositoryImpl(this.dataSource);

  @override
  Future<Patient> getPatient(String patientId) async {
    final docRef = _firestore.collection('users').doc(patientId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Seed dynamically to Firestore if not exists; ignore permission errors (dev env)
      final mock = dataSource.getPatient(patientId);
      try {
        await docRef.set({
          'name': mock.fullName,
          'fullName': mock.fullName,
          'role': 'patient',
          'age': mock.age,
          'gender': mock.gender,
          'bloodGroup': mock.bloodGroup,
          'weight': mock.weight,
          'bmi': mock.bmi,
          'symptoms': mock.symptoms,
          'latestVital': {
            'systolic': mock.latestVital.systolic,
            'diastolic': mock.latestVital.diastolic,
            'heartRate': mock.latestVital.heartRate,
            'bmi': mock.latestVital.bmi,
            'measuredAt': Timestamp.fromDate(mock.latestVital.measuredAt),
          },
        }, SetOptions(merge: true));

        // Also seed medical records
        final batch = _firestore.batch();
        for (var record in mock.records) {
          final recRef = _firestore.collection('medical_records').doc(record.id);
          batch.set(recRef, {
            'patientId': patientId,
            'visitDate': Timestamp.fromDate(record.visitDate),
            'doctorName': record.doctorName,
            'title': record.title,
            'diagnosis': record.diagnosis,
            'note': record.note,
          });
        }
        await batch.commit();
      } catch (_) {
        // Permission denied in dev env — continue with mock data
      }
      return mock;
    }

    final data = doc.data()!;
    final vitalData = data['latestVital'] as Map<String, dynamic>? ?? {};
    
    // Fetch records from Firestore, fall back to mock on permission error
    List<MedicalRecord> records = [];
    try {
      final recordsSnapshot = await _firestore
          .collection('medical_records')
          .where('patientId', isEqualTo: patientId)
          .get();

      records = recordsSnapshot.docs.map((rDoc) {
        final rData = rDoc.data();
        return MedicalRecord(
          id: rDoc.id,
          visitDate: (rData['visitDate'] as Timestamp).toDate(),
          doctorName: rData['doctorName'] ?? '',
          title: rData['title'] ?? '',
          diagnosis: rData['diagnosis'] ?? '',
          note: rData['note'],
        );
      }).toList();

      // Sort descending by date
      records.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    } catch (_) {
      // permission-denied or network error — use mock records
      records = dataSource.getPatient(patientId).records;
    }

    return Patient(
      id: patientId,
      code: 'BN-${patientId.padLeft(4, '0')}',
      fullName: data['name'] ?? data['fullName'] ?? 'Bệnh nhân',
      age: data['age'] ?? 54,
      gender: data['gender'] ?? 'Nam',
      bloodGroup: data['bloodGroup'] ?? 'O+',
      weight: (data['weight'] as num?)?.toDouble() ?? 72.0,
      bmi: (data['bmi'] as num?)?.toDouble() ?? 25.4,
      latestVital: VitalSign(
        systolic: vitalData['systolic'] ?? 142,
        diastolic: vitalData['diastolic'] ?? 92,
        heartRate: vitalData['heartRate'] ?? 88,
        bmi: (vitalData['bmi'] as num?)?.toDouble() ?? 25.4,
        measuredAt: vitalData['measuredAt'] != null
            ? (vitalData['measuredAt'] as Timestamp).toDate()
            : DateTime.now(),
      ),
      symptoms: List<String>.from(data['symptoms'] ?? const []),
      records: records.isEmpty ? dataSource.getPatient(patientId).records : records,
      avatarUrl: data['avatarUrl'],
    );
  }

  @override
  Future<List<MedicalRecord>> getRecentRecords(String patientId) async {
    final patient = await getPatient(patientId);
    return patient.records;
  }

  @override
  Future<void> savePatientNote(String patientId, String note) async {
    // Save note inside a sub-collection or inside patient notes field on Firestore
    await _firestore.collection('users').doc(patientId).update({
      'clinical_note': note,
      'notes': FieldValue.arrayUnion([note]),
    });
  }
}

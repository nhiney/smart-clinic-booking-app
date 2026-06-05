import '../../domain/entities/clinical_encounter.dart';
import '../../domain/entities/diagnosis_suggestion.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/medication_plan_item.dart';
import '../../domain/entities/medication_suggestion.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/treatment_plan.dart';
import '../../domain/entities/vital_sign.dart';

class ClinicalMockDataSource {
  ClinicalMockDataSource._();

  static final ClinicalMockDataSource instance = ClinicalMockDataSource._();

  final Map<String, Patient> _patients = {};
  final Map<String, ClinicalEncounter> _encounters = {};
  final Map<String, TreatmentPlan> _treatmentPlans = {};
  final Map<String, List<String>> _patientNotes = {};

  Patient getPatient(String patientId) {
    return _patients.putIfAbsent(patientId, () => _seedPatient(patientId));
  }

  List<MedicalRecord> getRecentRecords(String patientId) {
    return List<MedicalRecord>.from(getPatient(patientId).records);
  }

  Future<void> savePatientNote(String patientId, String note) async {
    final notes = _patientNotes.putIfAbsent(patientId, () => <String>[]);
    notes.insert(0, note);
  }

  List<String> getPatientNotes(String patientId) {
    return List<String>.from(_patientNotes[patientId] ?? const []);
  }

  ClinicalEncounter getEncounter(String encounterId) {
    return _encounters.putIfAbsent(encounterId, () => _seedEncounter(encounterId));
  }

  ClinicalEncounter saveEncounter(ClinicalEncounter encounter) {
    _encounters[encounter.id] = encounter;
    return encounter;
  }

  ClinicalEncounter completeEncounter(ClinicalEncounter encounter) {
    final completed = encounter.copyWith(
      completed: true,
      updatedAt: DateTime.now(),
    );
    _encounters[encounter.id] = completed;
    return completed;
  }

  TreatmentPlan getTreatmentPlan(String encounterId) {
    return _treatmentPlans.putIfAbsent(
      encounterId,
      () => _buildTreatmentPlan(_encounters[encounterId] ?? _seedEncounter(encounterId)),
    );
  }

  TreatmentPlan saveTreatmentPlan(TreatmentPlan plan) {
    _treatmentPlans[plan.encounterId] = plan;
    return plan;
  }

  List<DiagnosisSuggestion> getDiagnosisSuggestions() {
    return const [
      DiagnosisSuggestion(
        code: 'E11.9',
        name: 'ĐTĐ type 2 không biến chứng',
        confidence: 78,
      ),
      DiagnosisSuggestion(
        code: 'R07.4',
        name: 'Đau ngực không đặc hiệu',
        confidence: 65,
      ),
    ];
  }

  List<MedicationSuggestion> getMedicationSuggestions() {
    return const [
      MedicationSuggestion(
        name: 'Amlodipine',
        dosage: '5 mg',
        frequency: '1 lần/ngày',
        days: 30,
      ),
      MedicationSuggestion(
        name: 'Atorvastatin',
        dosage: '10 mg',
        frequency: '1 lần/ngày',
        days: 30,
      ),
    ];
  }

  Patient _seedPatient(String patientId) {
    final code = 'BN-${patientId.padLeft(4, '0')}';
    return Patient(
      id: patientId,
      code: code,
      fullName: 'Nguyễn Văn An',
      age: 54,
      gender: 'Nam',
      bloodGroup: 'O+',
      weight: 72,
      bmi: 25.4,
      latestVital: VitalSign(
        systolic: 142,
        diastolic: 92,
        heartRate: 88,
        bmi: 25.4,
        measuredAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      symptoms: const [
        'Đau ngực âm ỉ 3 ngày qua',
        'Lan cánh tay trái',
        'Khó thở',
        'Chóng mặt',
      ],
      records: [
        MedicalRecord(
          id: 'mr-001',
          visitDate: DateTime.now().subtract(const Duration(days: 4)),
          doctorName: 'BS. Phạm V. Đức',
          title: 'Tái khám tăng huyết áp',
          diagnosis: 'THA độ 2',
          note: 'Điều chỉnh liều thuốc, hẹn theo dõi sau 2 tuần.',
        ),
        MedicalRecord(
          id: 'mr-002',
          visitDate: DateTime.now().subtract(const Duration(days: 17)),
          doctorName: 'BS. Trần Minh Tâm',
          title: 'Khám tim mạch định kỳ',
          diagnosis: 'Theo dõi tăng HA',
          note: 'Khuyên giảm muối, tập luyện 30 phút/ngày.',
        ),
      ],
      avatarUrl: null,
    );
  }

  ClinicalEncounter _seedEncounter(String encounterId) {
    final patient = getPatient(encounterId);
    return ClinicalEncounter(
      id: encounterId,
      patientId: patient.id,
      patientName: patient.fullName,
      patientCode: patient.code,
      age: patient.age,
      gender: patient.gender,
      diagnosisBadge: 'THA độ 2',
      visitTimeLabel: '10:30',
      visitCount: 3,
      subjective: 'Đau ngực 3 ngày\nLan tay trái',
      objective: 'HA 142/92\nNT 88\nECG bất thường',
      assessment: 'THA độ 2',
      icdCodes: const ['I20.0', 'I10', 'E78.5'],
      medications: const [
        MedicationPlanItem(
          name: 'Amlodipine',
          dosage: '5 mg',
          timesPerDay: 1,
          days: 30,
        ),
      ],
      labTests: const ['CBC', 'HbA1C', 'Lipid', 'ECG'],
      imagingTests: const ['X-ray'],
      followUpDate: DateTime.now().add(const Duration(days: 14)),
      notes: 'Theo dõi huyết áp tại nhà, tái khám đúng hẹn.',
      completed: false,
      startedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      updatedAt: DateTime.now(),
    );
  }

  TreatmentPlan _buildTreatmentPlan(ClinicalEncounter encounter) {
    return TreatmentPlan(
      id: 'plan-${encounter.id}',
      encounterId: encounter.id,
      patientId: encounter.patientId,
      patientName: encounter.patientName,
      patientCode: encounter.patientCode,
      patientAge: encounter.age,
      patientGender: encounter.gender,
      diagnosisSummary: encounter.assessment,
      icdCodes: List<String>.from(encounter.icdCodes),
      medications: List<MedicationPlanItem>.from(encounter.medications),
      labTests: List<String>.from(encounter.labTests),
      imagingTests: List<String>.from(encounter.imagingTests),
      followUpDate: encounter.followUpDate,
      notes: encounter.notes,
      exportedPdfPath: null,
      updatedAt: DateTime.now(),
    );
  }
}

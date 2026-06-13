import '../entities/medical_record.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  Future<Patient> getPatient(String patientId);
  Future<List<MedicalRecord>> getRecentRecords(String patientId);
  Future<void> savePatientNote(String patientId, String note);
}

import '../entities/patient_profile.dart';
import '../repositories/profile_repository.dart';

class GetPatientProfile {
  final ProfileRepository repository;

  GetPatientProfile(this.repository);

  Future<PatientProfile?> call(String userId) {
    return repository.getPatientProfile(userId);
  }
}

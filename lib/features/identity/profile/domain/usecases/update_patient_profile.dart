import '../entities/patient_profile.dart';
import '../repositories/profile_repository.dart';

class UpdatePatientProfile {
  final ProfileRepository repository;

  UpdatePatientProfile(this.repository);

  Future<void> call(PatientProfile profile) {
    return repository.updatePatientProfile(profile);
  }
}

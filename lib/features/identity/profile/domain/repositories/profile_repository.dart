import '../entities/patient_profile.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getProfile(String userId);
  Future<void> updateProfile(UserEntity user);

  // Patient Profile Management
  Future<PatientProfile?> getPatientProfile(String userId);
  Future<void> updatePatientProfile(PatientProfile profile);
}


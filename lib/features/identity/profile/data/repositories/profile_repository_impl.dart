import '../../domain/entities/patient_profile.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity?> getProfile(String userId) async {
    return await remoteDatasource.getProfile(userId);
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    await remoteDatasource.updateProfile(user);
  }

  @override
  Future<PatientProfile?> getPatientProfile(String userId) async {
    return await remoteDatasource.getPatientProfile(userId);
  }

  @override
  Future<void> updatePatientProfile(PatientProfile profile) async {
    await remoteDatasource.updatePatientProfile(profile);
  }
}


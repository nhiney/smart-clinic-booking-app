import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDatasource remoteDatasource;

  DoctorRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<DoctorEntity>> getDoctors() async {
    return await remoteDatasource.getDoctors();
  }

  @override
  Future<DoctorEntity?> getDoctorById(String id) async {
    return await remoteDatasource.getDoctorById(id);
  }

  @override
  Future<List<DoctorEntity>> searchDoctors(String query) async {
    return await remoteDatasource.searchDoctors(query);
  }

  @override
  Future<List<DoctorEntity>> getDoctorsBySpecialty(String specialty) async {
    return await remoteDatasource.getDoctorsBySpecialty(specialty);
  }
}

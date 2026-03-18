import '../../domain/entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<List<DoctorEntity>> getDoctors();
  Future<DoctorEntity?> getDoctorById(String id);
  Future<List<DoctorEntity>> searchDoctors(String query);
  Future<List<DoctorEntity>> getDoctorsBySpecialty(String specialty);
}

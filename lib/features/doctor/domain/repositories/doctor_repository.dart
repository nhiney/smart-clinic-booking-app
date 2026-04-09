import '../../domain/entities/doctor_entity.dart';

abstract class DoctorRepository {
  Future<List<DoctorEntity>> getDoctors();
  Future<List<DoctorEntity>> getUnassignedDoctors();
  Future<void> assignDoctorToDepartment({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  });
  Future<void> updateDoctorProfile(DoctorEntity doctor);
  Future<DoctorEntity?> getDoctorProfile(String doctorId);
}

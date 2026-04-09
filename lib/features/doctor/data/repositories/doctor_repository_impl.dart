import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';
import '../models/doctor_model.dart';
import 'package:injectable/injectable.dart';

// Removed to use FirestoreDoctorRepository instead
class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDatasource remoteDatasource;

  DoctorRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<DoctorEntity>> getDoctors() async {
    return await remoteDatasource.getDoctors();
  }

  @override
  Future<List<DoctorEntity>> getUnassignedDoctors() async {
    return await remoteDatasource.getUnassignedDoctors();
  }

  @override
  Future<void> assignDoctorToDepartment({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  }) async {
    await remoteDatasource.assignDoctorToDepartment(
      doctorId: doctorId,
      hospitalId: hospitalId,
      departmentId: departmentId,
    );
  }

  @override
  Future<void> updateDoctorProfile(DoctorEntity doctor) async {
    final model = DoctorModel(
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      hospital: doctor.hospital,
      imageUrl: doctor.imageUrl,
      rating: doctor.rating,
      experience: doctor.experience,
      about: doctor.about,
      resumePdfUrl: doctor.resumePdfUrl,
      departmentId: doctor.departmentId,
      latitude: doctor.latitude,
      longitude: doctor.longitude,
      phone: doctor.phone,
      availableDays: doctor.availableDays,
      availableTimeSlots: doctor.availableTimeSlots,
    );
    await remoteDatasource.updateDoctorProfile(model);
  }

  @override
  Future<DoctorEntity?> getDoctorProfile(String doctorId) async {
    return await remoteDatasource.getDoctorById(doctorId);
  }
}

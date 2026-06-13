import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorDetailUseCase {
  final DoctorRepository repository;

  GetDoctorDetailUseCase(this.repository);

  Future<DoctorEntity?> call(String id) async {
    return repository.getDoctorProfile(id);
  }
}

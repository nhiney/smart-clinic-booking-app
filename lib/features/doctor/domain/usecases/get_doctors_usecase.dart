import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsUseCase {
  final DoctorRepository repository;

  GetDoctorsUseCase(this.repository);

  Future<List<DoctorEntity>> call() async {
    return await repository.getDoctors();
  }
}

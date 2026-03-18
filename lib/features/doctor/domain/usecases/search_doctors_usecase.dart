import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class SearchDoctorsUseCase {
  final DoctorRepository repository;

  SearchDoctorsUseCase(this.repository);

  Future<List<DoctorEntity>> call(String query) async {
    return await repository.searchDoctors(query);
  }
}

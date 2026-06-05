import '../../domain/entities/hospital_entity.dart';
import '../../domain/repositories/maps_repository.dart';

class GetHospitalsUseCase {
  final MapsRepository repository;

  GetHospitalsUseCase(this.repository);

  Future<List<HospitalEntity>> call() async {
    return await repository.getHospitals();
  }
}

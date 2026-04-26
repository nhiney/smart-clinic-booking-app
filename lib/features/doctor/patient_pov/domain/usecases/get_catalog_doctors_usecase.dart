import '../entities/doctor_catalog_query.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_catalog_repository.dart';

class GetCatalogDoctorsUseCase {
  final DoctorCatalogRepository _repository;

  GetCatalogDoctorsUseCase(this._repository);

  Future<List<DoctorEntity>> call(DoctorCatalogQuery query) {
    return _repository.search(query);
  }
}

import '../entities/doctor_entity.dart';
import '../repositories/doctor_catalog_repository.dart';

class GetCatalogDoctorDetailUseCase {
  final DoctorCatalogRepository _repository;

  GetCatalogDoctorDetailUseCase(this._repository);

  Future<DoctorEntity?> call(String doctorId) {
    return _repository.getDoctorById(doctorId);
  }
}

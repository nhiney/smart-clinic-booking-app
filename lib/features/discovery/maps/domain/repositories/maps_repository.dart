import '../entities/hospital_entity.dart';

abstract class MapsRepository {
  Future<List<HospitalEntity>> getHospitals();
  Future<List<HospitalEntity>> getHospitalsWithFilters({
    String? specialty,
    String? searchQuery,
  });
}

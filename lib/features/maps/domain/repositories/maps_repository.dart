import '../entities/hospital_entity.dart';

abstract class MapsRepository {
  Future<List<HospitalEntity>> getHospitals();
}

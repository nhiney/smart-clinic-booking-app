import '../entities/clinic_entity.dart';

abstract class MapsRepository {
  Future<List<ClinicEntity>> getClinics();
}

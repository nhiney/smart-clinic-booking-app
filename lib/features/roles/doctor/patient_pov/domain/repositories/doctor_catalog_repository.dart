import '../entities/doctor_catalog_query.dart';
import '../entities/doctor_entity.dart';

/// Patient-facing read-only catalog backed by the `doctors` collection.
abstract class DoctorCatalogRepository {
  Future<List<DoctorEntity>> search(DoctorCatalogQuery query);
  Future<DoctorEntity?> getDoctorById(String doctorId);
}

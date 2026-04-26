import '../../domain/entities/doctor_catalog_query.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_catalog_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorCatalogRepositoryImpl implements DoctorCatalogRepository {
  final DoctorRemoteDatasource _remote;

  DoctorCatalogRepositoryImpl(this._remote);

  @override
  Future<List<DoctorEntity>> search(DoctorCatalogQuery query) async {
    final raw = await _remote.searchDoctorsCatalog(query);
    if (query.userLatitude != null && query.userLongitude != null) {
      return _remote.withDistances(
        raw,
        query.userLatitude,
        query.userLongitude,
      );
    }
    return raw;
  }

  @override
  Future<DoctorEntity?> getDoctorById(String doctorId) async {
    return _remote.getDoctorCatalogById(doctorId);
  }
}

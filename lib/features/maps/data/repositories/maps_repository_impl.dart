import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_remote_datasource.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDatasource remoteDatasource;

  MapsRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ClinicEntity>> getClinics() async {
    // Try to get from clinics collection first, fallback to doctors
    final clinics = await remoteDatasource.getClinics();
    if (clinics.isNotEmpty) return clinics;
    return await remoteDatasource.getClinicsFromDoctors();
  }
}

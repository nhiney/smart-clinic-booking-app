import '../../domain/entities/medical_record_entity.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../datasources/medical_record_remote_datasource.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemoteDatasource remoteDatasource;

  MedicalRecordRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MedicalRecordEntity>> getRecordsByPatient(String patientId) async {
    return await remoteDatasource.getRecordsByPatient(patientId);
  }

  @override
  Future<MedicalRecordEntity?> getRecordById(String id) async {
    return await remoteDatasource.getRecordById(id);
  }
}

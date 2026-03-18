import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDatasource remoteDatasource;

  MedicationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MedicationEntity>> getMedicationsByPatient(String patientId) async {
    return await remoteDatasource.getMedicationsByPatient(patientId);
  }

  @override
  Future<MedicationEntity> addMedication(MedicationModel medication) async {
    return await remoteDatasource.addMedication(medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await remoteDatasource.deleteMedication(id);
  }

  @override
  Future<void> toggleMedication(String id, bool isActive) async {
    await remoteDatasource.toggleMedication(id, isActive);
  }
}

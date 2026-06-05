import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

class KycRepositoryImpl implements KYCRepository {
  final KycRemoteDatasource _datasource;

  KycRepositoryImpl(this._datasource);

  @override
  Future<void> submitApplication(Map<String, dynamic> data) =>
      _datasource.submitApplication(data);

  @override
  Future<List<dynamic>> getPendingApplications(String tenantId) =>
      _datasource.getPendingApplications(tenantId);

  @override
  Future<void> approveDoctor(String doctorUid, String targetTenantId) =>
      _datasource.approveDoctor(doctorUid, targetTenantId);
}

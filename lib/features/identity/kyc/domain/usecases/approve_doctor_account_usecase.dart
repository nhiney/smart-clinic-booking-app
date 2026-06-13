import 'package:dartz/dartz.dart';

import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/security/auth_user.dart';
import 'package:smart_clinic_booking/core/security/resource_context.dart';
import 'package:smart_clinic_booking/core/usecase/authorized_usecase.dart';
import '../repositories/kyc_repository.dart';

class ApproveDoctorParams {
  final String targetDoctorUid;
  final String targetTenantId;
  const ApproveDoctorParams({required this.targetDoctorUid, required this.targetTenantId});
}

class ApproveDoctorAccountUseCase extends AuthorizedUseCase<void, ApproveDoctorParams> {
  final KYCRepository repository;
  
  ApproveDoctorAccountUseCase(super.permissionManager, super.currentUser, this.repository);

  @override
  AppPermission get requiredPermission => AppPermission.approveDoctor;

  @override
  ResourceContext buildContext(ApproveDoctorParams params) => ResourceContext(resourceTenantId: params.targetTenantId);

  @override
  Future<Either<Failure, void>> execute(ApproveDoctorParams params) async {
    try {
      await repository.approveDoctor(params.targetDoctorUid, params.targetTenantId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

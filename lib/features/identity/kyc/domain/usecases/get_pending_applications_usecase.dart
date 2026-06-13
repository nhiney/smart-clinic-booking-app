import 'package:dartz/dartz.dart';

import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/security/auth_user.dart';
import 'package:smart_clinic_booking/core/security/resource_context.dart';
import 'package:smart_clinic_booking/core/usecase/authorized_usecase.dart';
import '../repositories/kyc_repository.dart';

class GetPendingParams {
  final String requestedTenantId;
  const GetPendingParams(this.requestedTenantId);
}

class GetPendingApplicationsUseCase extends AuthorizedUseCase<List<dynamic>, GetPendingParams> {
  final KYCRepository repository;
  
  GetPendingApplicationsUseCase(super.permissionManager, super.currentUser, this.repository);

  @override
  AppPermission get requiredPermission => AppPermission.viewKYCApplications;

  @override
  ResourceContext buildContext(GetPendingParams params) => ResourceContext(resourceTenantId: params.requestedTenantId);

  @override
  Future<Either<Failure, List<dynamic>>> execute(GetPendingParams params) async {
     try {
       final result = await repository.getPendingApplications(params.requestedTenantId);
       return Right(result);
     } catch (e) {
       return Left(ServerFailure(message: e.toString()));
     }
  }
}

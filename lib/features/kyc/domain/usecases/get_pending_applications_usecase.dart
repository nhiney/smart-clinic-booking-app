import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/security/auth_user.dart';
import '../../../../core/security/resource_context.dart';
import '../../../../core/usecase/authorized_usecase.dart';
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
       return Left(ServerFailure(e.toString()));
     }
  }
}

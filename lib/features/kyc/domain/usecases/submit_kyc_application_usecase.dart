import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/security/auth_user.dart';
import '../../../../core/security/resource_context.dart';
import '../../../../core/usecase/authorized_usecase.dart';
import '../repositories/kyc_repository.dart';

class SubmitKYCParams {
  final Map<String, dynamic> applicationData;
  const SubmitKYCParams(this.applicationData);
}

class SubmitKYCApplicationUseCase extends AuthorizedUseCase<void, SubmitKYCParams> {
  final KYCRepository repository;
  
  SubmitKYCApplicationUseCase(super.permissionManager, super.currentUser, this.repository);

  @override
  AppPermission get requiredPermission => AppPermission.submitKYCApplication;

  @override
  ResourceContext buildContext(SubmitKYCParams params) => const ResourceContext(); // No specific context constraint needed

  @override
  Future<Either<Failure, void>> execute(SubmitKYCParams params) async {
    try {
      await repository.submitApplication(params.applicationData);
      return const Right(null);
    } catch (e) {
      // In a real implementation, map specific exceptions to Failures.
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

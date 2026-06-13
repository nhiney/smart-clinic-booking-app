import 'package:dartz/dartz.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/usecase/usecase.dart';
import '../entities/health_summary.dart';
import '../repositories/home_repository.dart';

class GetHealthSummaryParams {
  final String userId;
  const GetHealthSummaryParams({required this.userId});
}

class GetHealthSummaryUseCase implements UseCase<HealthSummary, GetHealthSummaryParams> {
  final HomeRepository repository;

  const GetHealthSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, HealthSummary>> call(GetHealthSummaryParams params) {
    return repository.getHealthSummary(params.userId);
  }
}

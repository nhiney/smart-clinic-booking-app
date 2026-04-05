import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/health_article.dart';
import '../repositories/home_repository.dart';

class GetHealthNewsParams {
  final int limit;
  const GetHealthNewsParams({this.limit = 5});
}

class GetHealthNewsUseCase implements UseCase<List<HealthArticle>, GetHealthNewsParams> {
  final HomeRepository repository;

  const GetHealthNewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HealthArticle>>> call(GetHealthNewsParams params) {
    return repository.getHealthNews(limit: params.limit);
  }
}

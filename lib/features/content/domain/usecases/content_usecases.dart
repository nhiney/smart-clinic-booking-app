import 'package:dartz/dartz.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/usecase/usecase.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/domain/repositories/content_repository.dart';

class GetNewsParams {
  final int limit;
  final int offset;
  final String? category;
  GetNewsParams({this.limit = 10, this.offset = 0, this.category});
}

class GetNewsUseCase implements UseCase<List<HealthArticle>, GetNewsParams> {
  final ContentRepository repository;
  GetNewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<HealthArticle>>> call(GetNewsParams params) {
    return repository.getNews(limit: params.limit, offset: params.offset, category: params.category);
  }
}

class GetPricingUseCase implements UseCase<List<ServicePrice>, NoParams> {
  final ContentRepository repository;
  GetPricingUseCase(this.repository);

  @override
  Future<Either<Failure, List<ServicePrice>>> call(NoParams params) {
    return repository.getPricing();
  }
}

class GetSurveysUseCase implements UseCase<List<Survey>, NoParams> {
  final ContentRepository repository;
  GetSurveysUseCase(this.repository);

  @override
  Future<Either<Failure, List<Survey>>> call(NoParams params) {
    return repository.getSurveys();
  }
}

class SubmitSurveyVoteParams {
  final String surveyId;
  final String optionId;
  SubmitSurveyVoteParams({required this.surveyId, required this.optionId});
}

class SubmitSurveyVoteUseCase implements UseCase<void, SubmitSurveyVoteParams> {
  final ContentRepository repository;
  SubmitSurveyVoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitSurveyVoteParams params) {
    return repository.submitSurveyVote(params.surveyId, params.optionId);
  }
}

class SubmitContactFormParams {
  final String email;
  final String message;
  SubmitContactFormParams({required this.email, required this.message});
}

class SubmitContactFormUseCase implements UseCase<void, SubmitContactFormParams> {
  final ContentRepository repository;
  SubmitContactFormUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitContactFormParams params) {
    return repository.submitContactForm(params.email, params.message);
  }
}

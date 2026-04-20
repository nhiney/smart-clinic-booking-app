import 'package:dartz/dartz.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';

abstract class ContentRepository {
  Future<Either<Failure, List<HealthArticle>>> getNews({int limit = 10, int offset = 0, String? category});
  Future<Either<Failure, List<ServicePrice>>> getPricing();
  Future<Either<Failure, List<Survey>>> getSurveys();
  Future<Either<Failure, void>> submitSurveyVote(String surveyId, String optionId);
  Future<Either<Failure, void>> submitContactForm(String email, String message);

  // Health Library
  Future<Either<Failure, List<HealthLibraryArticle>>> getLibraryArticles({String? category, String? searchQuery});
  Future<Either<Failure, void>> bookmarkArticle(String userId, String articleId);
  Future<Either<Failure, void>> removeBookmark(String userId, String articleId);
  Future<Either<Failure, List<String>>> getBookmarkedIds(String userId);
}

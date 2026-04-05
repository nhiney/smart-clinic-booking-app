import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/health_summary.dart';
import '../entities/medication_reminder.dart';
import '../entities/health_article.dart';

/// Domain repository interface for the Home/Dashboard feature.
/// All implementations live in the data layer.
abstract class HomeRepository {
  /// Fetches health summary metrics for the given user.
  Future<Either<Failure, HealthSummary>> getHealthSummary(String userId);

  /// Fetches today's medication reminders for the given user.
  Future<Either<Failure, List<MedicationReminder>>> getMedicationReminders(String userId);

  /// Marks a medication reminder as taken.
  Future<Either<Failure, MedicationReminder>> markMedicationTaken(String reminderId);

  /// Fetches health news articles.
  Future<Either<Failure, List<HealthArticle>>> getHealthNews({int limit = 5});
}

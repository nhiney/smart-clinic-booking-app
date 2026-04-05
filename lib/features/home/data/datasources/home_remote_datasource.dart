import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/health_summary.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../config/dependency_injection/injection.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_models.dart';

abstract class HomeRemoteDatasource {
  Future<HealthSummary> getHealthSummary(String userId);
  Future<List<MedicationReminder>> getMedicationReminders(String userId);
  Future<MedicationReminder> markMedicationTaken(String reminderId);
  Future<List<HealthArticle>> getHealthNews({int limit = 5});
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final FirebaseFirestore _firestore;

  HomeRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<HealthSummary> getHealthSummary(String userId) async {
    if (getIt<AppConfigService>().config.useMockData) {
      debugPrint('[HOME] Using mock health summary');
      return HealthSummaryModel.mock(userId);
    }
    try {
      final doc = await _firestore
          .collection(getIt<AppConfigService>().config.healthSummaryCollection)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return HealthSummaryModel.fromJson(doc.data()!);
      }
      return HealthSummaryModel.mock(userId);
    } catch (e) {
      throw ServerException(message: 'Failed to load health summary: $e');
    }
  }

  @override
  Future<List<MedicationReminder>> getMedicationReminders(String userId) async {
    if (getIt<AppConfigService>().config.useMockData) {
      debugPrint('[HOME] Using mock medication reminders');
      return MedicationReminderModel.mockList();
    }
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(getIt<AppConfigService>().config.medicationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final startTimestamp = Timestamp.fromDate(startOfDay);
      final endTimestamp = Timestamp.fromDate(endOfDay);

      // Filter and sort locally to avoid the need for a composite index in Firestore
      final reminders = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final scheduledTime = data['scheduledTime'] as Timestamp?;
            if (scheduledTime == null) return false;
            return scheduledTime.compareTo(startTimestamp) >= 0 &&
                   scheduledTime.compareTo(endTimestamp) < 0;
          })
          .map((doc) => MedicationReminderModel.fromJson(doc.data(), doc.id))
          .toList();

      reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      return reminders;
    } catch (e) {
      throw ServerException(message: 'Failed to load medication reminders: $e');
    }
  }

  @override
  Future<MedicationReminder> markMedicationTaken(String reminderId) async {
    if (getIt<AppConfigService>().config.useMockData) {
      final mock = MedicationReminderModel.mockList()
          .firstWhere((m) => m.id == reminderId,
              orElse: () => MedicationReminderModel.mockList().first);
      return mock.copyWith(isTaken: true);
    }
    try {
      final ref = _firestore
          .collection(getIt<AppConfigService>().config.medicationsCollection)
          .doc(reminderId);
      await ref.update({'isTaken': true});
      final doc = await ref.get();
      return MedicationReminderModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException(message: 'Failed to mark medication as taken: $e');
    }
  }

  @override
  Future<List<HealthArticle>> getHealthNews({int limit = 5}) async {
    if (getIt<AppConfigService>().config.useMockData) {
      debugPrint('[HOME] Using mock health news');
      return HealthArticleModel.mockList();
    }
    try {
      final snapshot = await _firestore
          .collection(getIt<AppConfigService>().config.newsCollection)
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => HealthArticleModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to load health news: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/health_summary.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import 'package:smart_clinic_booking/core/services/app_config_service.dart';
import "package:smart_clinic_booking/shared/di/injection.dart";
import 'package:smart_clinic_booking/core/error/exceptions.dart';
import 'package:smart_clinic_booking/core/network/dio_client.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html;
import 'package:dio/dio.dart';
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
    // 1) VnExpress Sức khỏe RSS — embeds real article thumbnails, so images load
    //    reliably and it is one of the most up-to-date Vietnamese health sources.
    try {
      final vn = await _fetchVnExpressHealth(limit);
      if (vn.isNotEmpty) return vn;
    } catch (e) {
      debugPrint('VnExpress news failed, falling back to Google News: $e');
    }

    // 2) Google News RSS fallback (aggregated, but images often need scraping).
    try {
      final google = await _fetchGoogleNews(limit: limit);
      if (google.isNotEmpty) return google;
    } catch (e) {
      debugPrint('Google News failed: $e');
    }

    // 3) Firestore / mock fallback.
    if (getIt<AppConfigService>().config.useMockData) {
      return HealthArticleModel.mockList();
    }
    final snapshot = await _firestore
        .collection(getIt<AppConfigService>().config.newsCollection)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => HealthArticleModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Latest health articles from VnExpress with real thumbnail images.
  Future<List<HealthArticle>> _fetchVnExpressHealth(int limit) async {
    const url = 'https://vnexpress.net/rss/suc-khoe.rss';
    final response = await DioClient.dio.get(url);
    final document = XmlDocument.parse(response.data.toString());
    final items = document.findAllElements('item');

    final articles = items.take(limit).map((node) {
      final title = node.findElements('title').first.innerText.trim();
      final link = node.findElements('link').first.innerText.trim();
      final pubDateStr =
          node.findElements('pubDate').isNotEmpty ? node.findElements('pubDate').first.innerText : '';
      final description =
          node.findElements('description').isNotEmpty ? node.findElements('description').first.innerText : '';

      String? imageUrl;
      final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
      if (imgMatch != null) imageUrl = imgMatch.group(1);

      DateTime publishedAt;
      try {
        publishedAt = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(pubDateStr);
      } catch (_) {
        publishedAt = DateTime.now();
      }

      return HealthArticle(
        id: link.hashCode.toString(),
        title: title,
        summary: description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim(),
        imageUrl: imageUrl,
        source: 'VnExpress Sức khỏe',
        publishedAt: publishedAt,
        articleUrl: link,
      );
    }).where((a) => a.imageUrl != null && a.imageUrl!.startsWith('http')).toList();

    return articles;
  }

  /// Curated health images used when an article has no usable thumbnail
  /// (never shows the generic Google News logo).
  static const List<String> _healthPlaceholders = [
    'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=600&q=80',
    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&q=80',
    'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=600&q=80',
    'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=600&q=80',
    'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=600&q=80',
  ];

  Future<List<HealthArticle>> _fetchGoogleNews({int limit = 5}) async {
    final url = 'https://news.google.com/rss/search?q=${Uri.encodeComponent("y tế sức khỏe việt nam")}&hl=vi&gl=VN&ceid=VN:vi';
    final response = await DioClient.dio.get(url);
      final document = XmlDocument.parse(response.data.toString());
      final items = document.findAllElements('item');

      final initialArticles = items.take(limit).map((node) {
        final title = node.findElements('title').first.innerText;
        final link = node.findElements('link').first.innerText;
        final pubDateStr = node.findElements('pubDate').first.innerText;
        final source = node.findElements('source').first.innerText;
        final description = node.findElements('description').first.innerText;
        
        String? imageUrl;
        final imgMatch = RegExp(r'<img src="([^"]+)"').firstMatch(description);
        if (imgMatch != null) imageUrl = imgMatch.group(1);

        final cleanTitle = title.split(' - ').first;

        DateTime publishedAt;
        try {
          publishedAt = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(pubDateStr);
        } catch (_) {
          try {
             publishedAt = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US").parse(pubDateStr);
          } catch (_) {
             publishedAt = DateTime.now();
          }
        }

        return HealthArticle(
          id: link.hashCode.toString(),
          title: cleanTitle,
          summary: description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim(),
          imageUrl: imageUrl,
          source: source,
          publishedAt: publishedAt,
          articleUrl: link,
        );
      }).toList();

    // Enhance with the real article image; fall back to a curated health image
    // so a card never shows the generic Google News logo.
    final enhanced = await Future.wait(initialArticles.asMap().entries.map((entry) async {
      final i = entry.key;
      final article = entry.value;
      var img = article.imageUrl;
      final needsImage =
          img == null || img.contains('googleusercontent.com') || img.contains('news.google');
      if (needsImage && article.articleUrl != null) {
        img = await _fetchImageFromUrl(article.articleUrl!);
      }
      if (img == null || img.contains('google')) {
        img = _healthPlaceholders[i % _healthPlaceholders.length];
      }
      return article.copyWith(imageUrl: img);
    }));
    return enhanced;
  }

  Future<String?> _fetchImageFromUrl(String url) async {
    try {
      final response = await DioClient.dio.get(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          headers: {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
          },
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      
      if (response.statusCode == 200) {
        final document = html.parse(response.data.toString());
        final ogImage = document.querySelector('meta[property="og:image"]')?.attributes['content'] ??
                        document.querySelector('meta[name="og:image"]')?.attributes['content'];
        if (ogImage != null && ogImage.isNotEmpty) return ogImage;
        
        final twitterImage = document.querySelector('meta[name="twitter:image"]')?.attributes['content'];
        if (twitterImage != null && twitterImage.isNotEmpty) return twitterImage;
      }
    } catch (e) {
      debugPrint('Error fetching image from $url: $e');
    }
    return null;
  }
}

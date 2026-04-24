import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html;
import 'package:dio/dio.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:smart_clinic_booking/core/network/dio_client.dart';
import 'package:smart_clinic_booking/features/home/data/models/home_models.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/domain/repositories/content_repository.dart';
import 'package:smart_clinic_booking/features/content/data/models/content_models.dart';

class ContentRepositoryImpl implements ContentRepository {
  final FirebaseFirestore _firestore;
  final SQLiteHelper _sqliteHelper;

  ContentRepositoryImpl({
    FirebaseFirestore? firestore,
    SQLiteHelper? sqliteHelper,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _sqliteHelper = sqliteHelper ?? SQLiteHelper.instance;

  @override
  Future<Either<Failure, List<HealthArticle>>> getNews({
    int limit = 10, 
    int offset = 0, 
    String? category
  }) async {
    try {
      // Fetch from Google News RSS
      final articles = await _fetchFromGoogleNews(category: category);
      
      // Limit and offset (RSS usually returns ~30 items, we just take a slice)
      final slicedArticles = articles.skip(offset).take(limit).toList();

      // Cache the first page to SQLite
      if (offset == 0 && slicedArticles.isNotEmpty) {
        await _cacheNews(slicedArticles);
      }

      return Right(slicedArticles);
    } catch (e) {
      if (offset == 0) {
        final cached = await _getCachedNews();
        if (cached.isNotEmpty) return Right(cached);
      }
      // Fallback to Firestore if Google News fails
      return _fetchFromFirestore(limit: limit, offset: offset, category: category);
    }
  }

  Future<Either<Failure, List<HealthArticle>>> _fetchFromFirestore({
    required int limit, 
    required int offset, 
    String? category
  }) async {
    try {
      var query = _firestore.collection('news')
          .orderBy('publishedAt', descending: true)
          .limit(limit);

      if (category != null && category != 'Tất cả') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshots = await query.get();
      final articles = snapshots.docs.map((doc) {
        return HealthArticleModel.fromJson(doc.data(), doc.id);
      }).toList();

      return Right(articles);
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể tải tin tức: $e'));
    }
  }

  Future<List<HealthArticle>> _fetchFromGoogleNews({String? category}) async {
    final query = category != null && category != 'Tất cả' 
        ? 'y tế sức khỏe $category' 
        : 'y tế sức khỏe việt nam';
    
    final url = 'https://news.google.com/rss/search?q=${Uri.encodeComponent(query)}&hl=vi&gl=VN&ceid=VN:vi';
    
    final response = await DioClient.dio.get(url);
    final document = XmlDocument.parse(response.data.toString());
    final items = document.findAllElements('item');

    final initialArticles = items.map((node) {
      final title = node.findElements('title').first.innerText;
      final link = node.findElements('link').first.innerText;
      final pubDateStr = node.findElements('pubDate').first.innerText;
      final source = node.findElements('source').first.innerText;
      final description = node.findElements('description').first.innerText;
      
      // Extract image URL from description if present
      String? imageUrl;
      final imgMatch = RegExp(r'<img src="([^"]+)"').firstMatch(description);
      if (imgMatch != null) {
        imageUrl = imgMatch.group(1);
      }

      // Clean title
      final cleanTitle = title.split(' - ').first;

      DateTime publishedAt;
      try {
        publishedAt = _parseRFC822Date(pubDateStr);
      } catch (_) {
        publishedAt = DateTime.now();
      }

      return HealthArticle(
        id: link.hashCode.toString(),
        title: cleanTitle,
        summary: _stripHtml(description),
        imageUrl: imageUrl,
        source: source,
        publishedAt: publishedAt,
        articleUrl: link,
      );
    }).toList();

    // Enhance top 8 articles with images from their source pages if missing or low quality
    // We do this in parallel to keep it relatively fast
    final enhancedArticles = await Future.wait(
      initialArticles.asMap().entries.map((entry) async {
        final index = entry.key;
        final article = entry.value;
        
        if (index < 8 && article.articleUrl != null && (article.imageUrl == null || article.imageUrl!.contains('lh3.googleusercontent.com'))) {
          final scrapedImage = await _fetchImageFromUrl(article.articleUrl!);
          if (scrapedImage != null) {
            return HealthArticle(
              id: article.id,
              title: article.title,
              summary: article.summary,
              imageUrl: scrapedImage,
              source: article.source,
              publishedAt: article.publishedAt,
              articleUrl: article.articleUrl,
            );
          }
        }
        return article;
      })
    );

    return enhancedArticles;
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
        
        // Priority 1: og:image
        final ogImage = document.querySelector('meta[property="og:image"]')?.attributes['content'] ??
                        document.querySelector('meta[name="og:image"]')?.attributes['content'];
        if (ogImage != null && ogImage.isNotEmpty) return ogImage;
        
        // Priority 2: twitter:image
        final twitterImage = document.querySelector('meta[name="twitter:image"]')?.attributes['content'];
        if (twitterImage != null && twitterImage.isNotEmpty) return twitterImage;
        
        // Priority 3: first large-ish image
        final firstImg = document.querySelector('article img')?.attributes['src'] ?? 
                         document.querySelector('main img')?.attributes['src'];
        if (firstImg != null && firstImg.startsWith('http')) return firstImg;
      }
    } catch (e) {
      // Fail silently for image fetching errors
    }
    return null;
  }

  DateTime _parseRFC822Date(String dateString) {
    try {
      // RFC822: EEE, dd MMM yyyy HH:mm:ss Z
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US");
      return format.parse(dateString);
    } catch (e) {
      // Fallback for some common variations
      try {
        return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", "en_US").parse(dateString);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
  }

  @override
  Future<Either<Failure, List<ServicePrice>>> getPricing() async {
    try {
      final snapshots = await _firestore.collection('pricing').orderBy('category').get();
      return Right(snapshots.docs.map((doc) => ServicePriceModel.fromFirestore(doc.data(), doc.id)).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể tải bảng giá: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Survey>>> getSurveys() async {
    try {
      final snapshots = await _firestore.collection('surveys').get();
      return Right(snapshots.docs.map((doc) => SurveyModel.fromFirestore(doc.data(), doc.id)).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể tải khảo sát: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitSurveyVote(String surveyId, String optionId) async {
    try {
      await _firestore.collection('surveys').doc(surveyId).update({
        'results.$optionId': FieldValue.increment(1),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Bình chọn thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitSurveyResponse({
    required String surveyId,
    required String userId,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _firestore.collection('survey_responses').add({
        'surveyId': surveyId,
        'userId': userId,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('surveys').doc(surveyId).update({
        'responseCount': FieldValue.increment(1),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Gửi khảo sát thất bại: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> submitContactForm(String email, String message) async {
    try {
      await _firestore.collection('contact_requests').add({
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'new',
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Gửi yêu cầu thất bại: $e'));
    }
  }

  // ─── HEALTH LIBRARY ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<HealthLibraryArticle>>> getLibraryArticles({
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = _firestore.collection('health_library').orderBy('publishedAt', descending: true).limit(30);
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      final snapshots = await query.get();
      var articles = snapshots.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return HealthLibraryArticle.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        articles = articles.where((a) => a.title.toLowerCase().contains(q) || a.content.toLowerCase().contains(q) || a.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      return Right(articles);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load health library: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> bookmarkArticle(String userId, String articleId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('bookmarks').doc(articleId).set({
        'articleId': articleId,
        'savedAt': FieldValue.serverTimestamp(),
        'collection': 'health_library',
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to bookmark: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String userId, String articleId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('bookmarks').doc(articleId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove bookmark: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBookmarkedIds(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).collection('bookmarks').get();
      return Right(snapshot.docs.map((d) => d.id).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load bookmarks: $e'));
    }
  }

  // --- Caching Helpers ---

  Future<void> _cacheNews(List<HealthArticle> articles) async {
    final db = await _sqliteHelper.database;
    final batch = db.batch();
    batch.delete('news_cache');
    for (var art in articles) {
      final cacheModel = HealthArticleCacheModel(
        id: art.id,
        title: art.title,
        summary: art.summary,
        imageUrl: art.imageUrl,
        source: art.source,
        publishedAt: art.publishedAt,
        articleUrl: art.articleUrl,
      );
      batch.insert('news_cache', {
        'id': art.id,
        'data': jsonEncode(cacheModel.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<HealthArticle>> _getCachedNews() async {
    final db = await _sqliteHelper.database;
    final maps = await db.query('news_cache');
    return maps.map((map) {
      return HealthArticleCacheModel.fromJson(jsonDecode(map['data'] as String));
    }).toList();
  }
}

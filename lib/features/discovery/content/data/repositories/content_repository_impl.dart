import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html;
import 'package:dio/dio.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:smart_clinic_booking/core/network/dio_client.dart';
import 'package:smart_clinic_booking/features/discovery/home/data/models/home_models.dart';
import 'package:smart_clinic_booking/features/discovery/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/discovery/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/discovery/content/domain/repositories/content_repository.dart';
import 'package:smart_clinic_booking/features/discovery/content/data/models/content_models.dart';

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
      // 1) VnExpress Sức khỏe RSS first — its feed embeds real article
      //    thumbnails, so images load reliably and stay up to date.
      var articles = await _fetchFromVnExpress(category: category);

      // 2) Fall back to Google News RSS aggregation if VnExpress returns nothing.
      if (articles.isEmpty) {
        articles = await _fetchFromGoogleNews(category: category);
      }

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

  /// Curated health images used when an article has no usable thumbnail,
  /// so a card never falls back to the generic Google News logo.
  static const List<String> _healthPlaceholders = [
    'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=600&q=80',
    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&q=80',
    'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=600&q=80',
    'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=600&q=80',
    'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=600&q=80',
  ];

  /// Latest Vietnamese health articles from VnExpress, with real thumbnails
  /// taken directly from the RSS feed (no per-article scraping needed).
  Future<List<HealthArticle>> _fetchFromVnExpress({String? category}) async {
    const url = 'https://vnexpress.net/rss/suc-khoe.rss';
    try {
      final response = await DioClient.dio.get(url);
      final document = XmlDocument.parse(response.data.toString());
      final items = document.findAllElements('item');

      return items.map((node) {
        final title = node.findElements('title').first.innerText.trim();
        final link = node.findElements('link').first.innerText.trim();
        final pubDateStr =
            node.findElements('pubDate').isNotEmpty ? node.findElements('pubDate').first.innerText : '';
        final description =
            node.findElements('description').isNotEmpty ? node.findElements('description').first.innerText : '';

        String? imageUrl;
        final imgMatch = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
        if (imgMatch != null) {
          imageUrl = imgMatch.group(1);
          if (imageUrl!.startsWith('//')) imageUrl = 'https:$imageUrl';
        }

        DateTime publishedAt;
        try {
          publishedAt = _parseRFC822Date(pubDateStr);
        } catch (_) {
          publishedAt = DateTime.now();
        }

        return HealthArticle(
          id: link.hashCode.toString(),
          title: title,
          summary: _stripHtml(description),
          imageUrl: imageUrl,
          source: 'VnExpress Sức khỏe',
          publishedAt: publishedAt,
          articleUrl: link,
        );
      }).where((a) => a.imageUrl != null && a.imageUrl!.startsWith('http')).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<HealthArticle>> _fetchFromGoogleNews({String? category}) async {
    final query = category != null && category != 'Tất cả' 
        ? 'y tế sức khỏe $category' 
        : 'tin tức y tế sức khỏe mới nhất việt nam';
    
    // Add time filter for freshness
    final url = 'https://news.google.com/rss/search?q=${Uri.encodeComponent(query)}+when:7d&hl=vi&gl=VN&ceid=VN:vi';
    
    try {
      final response = await DioClient.dio.get(url);
      final document = XmlDocument.parse(response.data.toString());
      final items = document.findAllElements('item');

      final initialArticles = items.map((node) {
        final title = node.findElements('title').first.innerText;
        final link = node.findElements('link').first.innerText;
        final pubDateStr = node.findElements('pubDate').first.innerText;
        final sourceNodes = node.findElements('source');
        final source = sourceNodes.isNotEmpty 
            ? sourceNodes.first.innerText 
            : 'Tin tức Y tế';
        final description = node.findElements('description').first.innerText;
        
        // Extract image URL from description if present
        String? imageUrl;
        final imgMatch = RegExp(r'<img src="([^"]+)"').firstMatch(description);
        if (imgMatch != null) {
          imageUrl = imgMatch.group(1);
          // If it's a relative URL, it might not work
          if (imageUrl!.startsWith('//')) imageUrl = 'https:$imageUrl';
        }

        // Clean title - remove the source suffix usually added by Google News
        final cleanTitle = title.contains(' - ') 
            ? title.substring(0, title.lastIndexOf(' - ')) 
            : title;

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

      // Take only the most recent 15 articles to avoid heavy scraping
      final topArticles = initialArticles.take(15).toList();

      // Enhance articles with images from their source pages if missing or low quality
      final enhancedArticles = await Future.wait(
        topArticles.asMap().entries.map((entry) async {
          final index = entry.key;
          final article = entry.value;
          
          // Only scrape images for top articles or if image is missing/low quality
          bool needsImage = article.imageUrl == null ||
                           article.imageUrl!.isEmpty ||
                           article.imageUrl!.contains('googleusercontent.com') ||
                           article.imageUrl!.contains('news.google');

          String? img = article.imageUrl;
          if (index < 10 && needsImage && article.articleUrl != null) {
            img = await _fetchImageFromUrl(article.articleUrl!);
          }
          // Never show the Google News logo — use a curated health image instead.
          if (img == null || img.isEmpty || img.contains('google')) {
            img = _healthPlaceholders[index % _healthPlaceholders.length];
          }
          return article.copyWith(imageUrl: img);
        })
      );

      return enhancedArticles;
    } catch (e) {
      return [];
    }
  }

  Future<String?> _fetchImageFromUrl(String url) async {
    try {
      final response = await DioClient.dio.get(
        url,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      if (response.statusCode == 200) {
        final content = response.data.toString();
        final document = html.parse(content);
        
        // 1. og:image
        String? imageUrl = document.querySelector('meta[property="og:image"]')?.attributes['content'] ??
                           document.querySelector('meta[name="og:image"]')?.attributes['content'];
        
        // 2. twitter:image
        if (imageUrl == null || imageUrl.isEmpty) {
          imageUrl = document.querySelector('meta[name="twitter:image"]')?.attributes['content'] ??
                     document.querySelector('meta[property="twitter:image"]')?.attributes['content'];
        }
        
        // 3. JSON-LD
        if (imageUrl == null || imageUrl.isEmpty) {
          final scripts = document.querySelectorAll('script[type="application/ld+json"]');
          for (final script in scripts) {
            try {
              final json = jsonDecode(script.text);
              if (json is Map) {
                if (json['image'] is String) {
                  imageUrl = json['image'];
                  break;
                } else if (json['image'] is Map && json['image']['url'] is String) {
                  imageUrl = json['image']['url'];
                  break;
                }
              }
            } catch (_) {}
          }
        }
        
        // 4. Fallback to main image
        if (imageUrl == null || imageUrl.isEmpty) {
          imageUrl = document.querySelector('article img')?.attributes['src'] ?? 
                     document.querySelector('.main-content img')?.attributes['src'] ??
                     document.querySelector('.article-content img')?.attributes['src'];
        }

        if (imageUrl != null) {
          if (imageUrl.startsWith('//')) imageUrl = 'https:$imageUrl';
          if (!imageUrl.startsWith('http')) {
            // Handle relative paths
            final uri = Uri.parse(url);
            imageUrl = '${uri.scheme}://${uri.host}$imageUrl';
          }
          return imageUrl;
        }
      }
    } catch (e) {
      // Fail silently
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
      debugPrint('[SURVEY] Submitting response for survey: $surveyId, user: $userId');
      await _firestore.collection('survey_responses').add({
        'surveyId': surveyId,
        'userId': userId,
        'answers': answers,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('[SURVEY] Updating response count for survey: $surveyId');
      await _firestore.collection('surveys').doc(surveyId).update({
        'responseCount': FieldValue.increment(1),
      });
      
      debugPrint('[SURVEY] Submission successful');
      return const Right(null);
    } catch (e) {
      debugPrint('[SURVEY] Submission failed: $e');
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

  static final List<HealthLibraryArticle> _demoLibraryArticles = [
    HealthLibraryArticle(
      id: 'demo_1',
      title: '5 thói quen giúp tim mạch khoẻ mạnh mỗi ngày',
      content: 'Tim mạch là cơ quan quan trọng nhất của cơ thể. Để bảo vệ sức khoẻ tim mạch, bạn cần duy trì lối sống lành mạnh bao gồm tập thể dục đều đặn, ăn uống cân bằng, không hút thuốc và kiểm soát căng thẳng. Tập aerobic 30 phút mỗi ngày giúp tăng cường sức khoẻ tim mạch. Chế độ ăn ít muối, ít chất béo bão hòa cũng rất quan trọng.',
      category: 'Tim mạch',
      imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=600&q=80',
      tags: ['tim mạch', 'sức khoẻ', 'thói quen'],
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HealthLibraryArticle(
      id: 'demo_2',
      title: 'Kiểm soát đường huyết hiệu quả cho người tiểu đường',
      content: 'Tiểu đường type 2 có thể được kiểm soát tốt thông qua chế độ ăn uống hợp lý và vận động thể chất. Người bệnh cần theo dõi đường huyết thường xuyên, dùng thuốc đúng giờ và tái khám định kỳ. Tránh thức ăn nhiều đường tinh luyện, tăng cường rau xanh và ngũ cốc nguyên hạt.',
      category: 'Tiểu đường',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&q=80',
      tags: ['tiểu đường', 'đường huyết', 'dinh dưỡng'],
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    HealthLibraryArticle(
      id: 'demo_3',
      title: 'Dinh dưỡng cân bằng: Bí quyết cho sức khoẻ toàn diện',
      content: 'Một chế độ dinh dưỡng cân bằng bao gồm đủ 4 nhóm thực phẩm chính: tinh bột, đạm, béo và vitamin-khoáng chất. Uống đủ 2 lít nước mỗi ngày. Ăn nhiều rau củ quả để bổ sung chất xơ và chất chống oxy hóa. Hạn chế đồ ăn chế biến sẵn, thức ăn nhanh và đồ uống có đường.',
      category: 'Dinh dưỡng',
      imageUrl: 'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=600&q=80',
      tags: ['dinh dưỡng', 'ăn uống', 'sức khoẻ'],
      publishedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    HealthLibraryArticle(
      id: 'demo_4',
      title: 'Sức khoẻ tâm lý: Cách giảm stress hiệu quả',
      content: 'Stress kéo dài ảnh hưởng tiêu cực đến cả sức khoẻ thể chất lẫn tinh thần. Các phương pháp giảm stress hiệu quả bao gồm: thiền định, yoga, tập hít thở sâu, nghe nhạc và dành thời gian cho sở thích cá nhân. Ngủ đủ 7-8 tiếng mỗi đêm cũng giúp cải thiện tâm trạng đáng kể.',
      category: 'Tâm lý',
      imageUrl: 'https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=600&q=80',
      tags: ['tâm lý', 'stress', 'thiền định'],
      publishedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    HealthLibraryArticle(
      id: 'demo_5',
      title: 'Phòng ngừa bệnh hô hấp trong mùa lạnh',
      content: 'Mùa lạnh là thời điểm dễ mắc các bệnh hô hấp như cảm lạnh, cúm và viêm phổi. Để phòng ngừa, cần tiêm vaccine cúm hàng năm, rửa tay thường xuyên, đeo khẩu trang nơi đông người và giữ ấm cơ thể. Uống nhiều nước ấm và bổ sung vitamin C giúp tăng cường miễn dịch.',
      category: 'Hô hấp',
      imageUrl: 'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=600&q=80',
      tags: ['hô hấp', 'cảm cúm', 'phòng bệnh'],
      publishedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    HealthLibraryArticle(
      id: 'demo_6',
      title: 'Chăm sóc sức khoẻ xương khớp đúng cách',
      content: 'Bệnh xương khớp ngày càng phổ biến, đặc biệt ở người cao tuổi. Để phòng ngừa, cần bổ sung canxi và vitamin D đầy đủ, tập thể dục nhẹ nhàng như bơi lội và đi bộ, tránh mang vác nặng sai tư thế. Kiểm tra mật độ xương định kỳ giúp phát hiện sớm nguy cơ loãng xương.',
      category: 'Cơ xương khớp',
      imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=600&q=80',
      tags: ['xương khớp', 'canxi', 'vận động'],
      publishedAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    HealthLibraryArticle(
      id: 'demo_7',
      title: 'Sức khoẻ trẻ em: Lịch tiêm chủng quan trọng cần biết',
      content: 'Tiêm chủng đầy đủ là biện pháp phòng bệnh hiệu quả nhất cho trẻ em. Chương trình tiêm chủng quốc gia bao gồm các vaccine phòng bạch hầu, ho gà, uốn ván, sởi, rubella và nhiều bệnh khác. Cha mẹ cần tuân thủ lịch tiêm chủng và theo dõi phản ứng sau tiêm của trẻ.',
      category: 'Nhi khoa',
      imageUrl: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=600&q=80',
      tags: ['nhi khoa', 'tiêm chủng', 'trẻ em'],
      publishedAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

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

      if (articles.isEmpty) articles = List.of(_demoLibraryArticles);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        articles = articles.where((a) => a.title.toLowerCase().contains(q) || a.content.toLowerCase().contains(q) || a.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      if (category != null && category.isNotEmpty) {
        articles = articles.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
      }
      return Right(articles);
    } catch (e) {
      var fallback = List.of(_demoLibraryArticles);
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        fallback = fallback.where((a) => a.title.toLowerCase().contains(q) || a.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      if (category != null && category.isNotEmpty) {
        fallback = fallback.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
      }
      return Right(fallback);
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

  @override
  Future<Either<Failure, List<String>>> getUserRespondedSurveyIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('survey_responses')
          .where('userId', isEqualTo: userId)
          .get();
      final ids = snapshot.docs.map((d) => (d.data()['surveyId'] ?? '').toString()).toSet().toList();
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể tải lịch sử khảo sát: $e'));
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

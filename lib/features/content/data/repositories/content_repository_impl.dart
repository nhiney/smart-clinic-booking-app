import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
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

      // Cache the first page to SQLite
      if (offset == 0) {
        await _cacheNews(articles);
      }

      return Right(articles);
    } catch (e) {
      if (offset == 0) {
        final cached = await _getCachedNews();
        if (cached.isNotEmpty) return Right(cached);
      }
      return Left(ServerFailure(message: 'Không thể tải tin tức: $e'));
    }
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

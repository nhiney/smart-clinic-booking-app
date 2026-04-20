import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/content/domain/repositories/content_repository.dart';
import 'package:smart_clinic_booking/features/content/data/repositories/content_repository_impl.dart';
import 'package:smart_clinic_booking/core/usecase/usecase.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
});

// --- News Provider ---

class NewsState {
  final List<HealthArticle> articles;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;

  NewsState({this.articles = const [], this.isLoading = false, this.isFetchingMore = false, this.error});
}

class NewsNotifier extends StateNotifier<NewsState> {
  final ContentRepository repository;
  NewsNotifier(this.repository) : super(NewsState());

  Future<void> loadNews({String? category, bool refresh = false}) async {
    if (refresh) {
      state = NewsState(isLoading: true);
    } else if (state.articles.isEmpty) {
      state = NewsState(isLoading: true);
    }

    final result = await repository.getNews(category: category, limit: 10, offset: refresh ? 0 : state.articles.length);
    result.fold(
      (failure) => state = NewsState(error: failure.message, articles: state.articles),
      (newArticles) {
        if (refresh) {
          state = NewsState(articles: newArticles);
        } else {
          state = NewsState(articles: [...state.articles, ...newArticles]);
        }
      },
    );
  }
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.watch(contentRepositoryProvider));
});

// --- Pricing Provider ---

final pricingProvider = FutureProvider<List<ServicePrice>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  final result = await repo.getPricing();
  return result.fold((l) => throw l.message, (r) => r);
});

// --- Survey Provider ---

class SurveyNotifier extends StateNotifier<AsyncValue<List<Survey>>> {
  final ContentRepository repository;
  SurveyNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> loadSurveys() async {
    state = const AsyncValue.loading();
    final result = await repository.getSurveys();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (surveys) => state = AsyncValue.data(surveys),
    );
  }

  Future<bool> vote(String surveyId, String optionId) async {
    final result = await repository.submitSurveyVote(surveyId, optionId);
    return result.fold((l) => false, (r) {
      loadSurveys(); // Refresh
      return true;
    });
  }
}

final surveyProvider = StateNotifierProvider<SurveyNotifier, AsyncValue<List<Survey>>>((ref) {
  return SurveyNotifier(ref.watch(contentRepositoryProvider))..loadSurveys();
});

// --- Contact Form Logic ---

final contactFormSubmitProvider = Provider((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return (String email, String message) => repo.submitContactForm(email, message);
});

// --- Health Library Provider ---

class LibraryState {
  final List<HealthLibraryArticle> articles;
  final Set<String> bookmarkedIds;
  final bool isLoading;
  final String? error;

  const LibraryState({
    this.articles = const [],
    this.bookmarkedIds = const {},
    this.isLoading = false,
    this.error,
  });
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final ContentRepository repository;
  LibraryNotifier(this.repository) : super(const LibraryState());

  Future<void> loadArticles({String? category, String? searchQuery}) async {
    state = LibraryState(isLoading: true, bookmarkedIds: state.bookmarkedIds);
    final result = await repository.getLibraryArticles(category: category, searchQuery: searchQuery);
    result.fold(
      (f) => state = LibraryState(error: f.message, bookmarkedIds: state.bookmarkedIds),
      (articles) => state = LibraryState(
        articles: articles.map((a) => a.copyWith(isBookmarked: state.bookmarkedIds.contains(a.id))).toList(),
        bookmarkedIds: state.bookmarkedIds,
      ),
    );
  }

  Future<void> loadBookmarks(String userId) async {
    final result = await repository.getBookmarkedIds(userId);
    result.fold((_) {}, (ids) {
      final idSet = ids.toSet();
      state = LibraryState(
        articles: state.articles.map((a) => a.copyWith(isBookmarked: idSet.contains(a.id))).toList(),
        bookmarkedIds: idSet,
      );
    });
  }

  Future<void> toggleBookmark(String userId, String articleId) async {
    final isBookmarked = state.bookmarkedIds.contains(articleId);
    if (isBookmarked) {
      await repository.removeBookmark(userId, articleId);
      final newIds = {...state.bookmarkedIds}..remove(articleId);
      state = LibraryState(
        articles: state.articles.map((a) => a.id == articleId ? a.copyWith(isBookmarked: false) : a).toList(),
        bookmarkedIds: newIds,
      );
    } else {
      await repository.bookmarkArticle(userId, articleId);
      final newIds = {...state.bookmarkedIds, articleId};
      state = LibraryState(
        articles: state.articles.map((a) => a.id == articleId ? a.copyWith(isBookmarked: true) : a).toList(),
        bookmarkedIds: newIds,
      );
    }
  }
}

final healthLibraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  return LibraryNotifier(ref.watch(contentRepositoryProvider));
});

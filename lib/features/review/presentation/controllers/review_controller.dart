import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/review/domain/entities/review_entity.dart';
import 'package:smart_clinic_booking/features/review/domain/repositories/review_repository.dart';
import 'package:smart_clinic_booking/features/review/data/repositories/review_repository_impl.dart';

class ReviewState {
  final bool isLoading;
  final List<ReviewEntity> reviews;
  final double averageRating;
  final bool userHasReviewed;
  final String? error;

  const ReviewState({
    this.isLoading = false,
    this.reviews = const [],
    this.averageRating = 0.0,
    this.userHasReviewed = false,
    this.error,
  });

  ReviewState copyWith({
    bool? isLoading,
    List<ReviewEntity>? reviews,
    double? averageRating,
    bool? userHasReviewed,
    String? error,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      userHasReviewed: userHasReviewed ?? this.userHasReviewed,
      error: error,
    );
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => ReviewRepositoryImpl());

// Hospital reviews
final reviewControllerProvider = StateNotifierProvider.family<ReviewController, ReviewState, String>((ref, hospitalId) {
  return ReviewController(repository: ref.watch(reviewRepositoryProvider), hospitalId: hospitalId);
});

// Doctor reviews
final doctorReviewControllerProvider = StateNotifierProvider.family<DoctorReviewController, ReviewState, String>((ref, doctorId) {
  return DoctorReviewController(repository: ref.watch(reviewRepositoryProvider), doctorId: doctorId);
});

class ReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository repository;
  final String hospitalId;

  ReviewController({required this.repository, required this.hospitalId}) : super(const ReviewState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    repository.getReviews(hospitalId).listen((reviews) async {
      final average = await repository.getAverageRating(hospitalId);
      state = state.copyWith(isLoading: false, reviews: reviews, averageRating: average);
    }, onError: (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    });
  }

  Future<void> checkUserReviewed(String userId) async {
    final has = await repository.hasUserReviewed(userId: userId, hospitalId: hospitalId);
    state = state.copyWith(userHasReviewed: has);
  }

  Future<bool> addReview({
    required String userId,
    required double rating,
    required String comment,
    String? userName,
    String? userAvatar,
    String? doctorId,
  }) async {
    if (state.userHasReviewed) return false;
    try {
      final review = ReviewEntity(
        id: '',
        userId: userId,
        hospitalId: hospitalId,
        doctorId: doctorId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        userName: userName,
        userAvatar: userAvatar,
      );
      await repository.addReview(review);
      state = state.copyWith(userHasReviewed: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> toggleHelpful(String reviewId, String userId) async {
    await repository.toggleHelpful(reviewId, userId);
  }
}

class DoctorReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository repository;
  final String doctorId;

  DoctorReviewController({required this.repository, required this.doctorId}) : super(const ReviewState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    repository.getDoctorReviews(doctorId).listen((reviews) async {
      final average = await repository.getDoctorAverageRating(doctorId);
      state = state.copyWith(isLoading: false, reviews: reviews, averageRating: average);
    }, onError: (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    });
  }

  Future<void> checkUserReviewed(String userId) async {
    final has = await repository.hasUserReviewed(userId: userId, doctorId: doctorId);
    state = state.copyWith(userHasReviewed: has);
  }

  Future<bool> addReview({
    required String userId,
    required String hospitalId,
    required double rating,
    required String comment,
    String? userName,
    String? userAvatar,
  }) async {
    if (state.userHasReviewed) return false;
    try {
      final review = ReviewEntity(
        id: '',
        userId: userId,
        hospitalId: hospitalId,
        doctorId: doctorId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        userName: userName,
        userAvatar: userAvatar,
      );
      await repository.addReview(review);
      state = state.copyWith(userHasReviewed: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> toggleHelpful(String reviewId, String userId) async {
    await repository.toggleHelpful(reviewId, userId);
  }
}

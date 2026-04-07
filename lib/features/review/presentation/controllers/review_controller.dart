import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/review/domain/entities/review_entity.dart';
import 'package:smart_clinic_booking/features/review/domain/repositories/review_repository.dart';
import 'package:smart_clinic_booking/features/review/data/repositories/review_repository_impl.dart';

class ReviewState {
  final bool isLoading;
  final List<ReviewEntity> reviews;
  final double averageRating;
  final String? error;

  ReviewState({
    this.isLoading = false,
    this.reviews = const [],
    this.averageRating = 0.0,
    this.error,
  });

  ReviewState copyWith({
    bool? isLoading,
    List<ReviewEntity>? reviews,
    double? averageRating,
    String? error,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      error: error,
    );
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl();
});

final reviewControllerProvider = StateNotifierProvider.family<ReviewController, ReviewState, String>((ref, hospitalId) {
  final repository = ref.watch(reviewRepositoryProvider);
  return ReviewController(repository: repository, hospitalId: hospitalId);
});

class ReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository repository;
  final String hospitalId;

  ReviewController({required this.repository, required this.hospitalId}) : super(ReviewState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    repository.getReviews(hospitalId).listen((reviews) async {
      final average = await repository.getAverageRating(hospitalId);
      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
        averageRating: average,
      );
    }, onError: (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    });
  }

  Future<bool> addReview({
    required String userId,
    required double rating,
    required String comment,
    String? userName,
    String? userAvatar,
    String? doctorId,
  }) async {
    try {
      final review = ReviewEntity(
        id: '', // Firestore will generate
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
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

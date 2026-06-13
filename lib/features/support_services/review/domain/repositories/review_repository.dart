import 'package:smart_clinic_booking/features/support_services/review/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Stream<List<ReviewEntity>> getReviews(String hospitalId);
  Stream<List<ReviewEntity>> getDoctorReviews(String doctorId);
  Future<void> addReview(ReviewEntity review);
  Future<double> getAverageRating(String hospitalId);
  Future<double> getDoctorAverageRating(String doctorId);
  Future<bool> hasUserReviewed({required String userId, String? hospitalId, String? doctorId});
  Future<void> toggleHelpful(String reviewId, String userId);
  Future<List<ReviewEntity>> getUserReviews(String userId);
  Future<void> respondToReview(String reviewId, String response);
}

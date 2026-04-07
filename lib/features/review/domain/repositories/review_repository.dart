import 'package:smart_clinic_booking/features/review/domain/entities/review_entity.dart';
import 'package:smart_clinic_booking/features/review/data/models/review_model.dart';

abstract class ReviewRepository {
  Stream<List<ReviewEntity>> getReviews(String hospitalId);
  Future<void> addReview(ReviewEntity review);
  Future<double> getAverageRating(String hospitalId);
}

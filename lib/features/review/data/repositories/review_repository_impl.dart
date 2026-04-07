import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/review/domain/entities/review_entity.dart';
import 'package:smart_clinic_booking/features/review/domain/repositories/review_repository.dart';
import 'package:smart_clinic_booking/features/review/data/models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ReviewEntity>> getReviews(String hospitalId) {
    return _firestore
        .collection('reviews')
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addReview(ReviewEntity review) async {
    final reviewModel = ReviewModel(
      id: review.id,
      userId: review.userId,
      hospitalId: review.hospitalId,
      doctorId: review.doctorId,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      userName: review.userName,
      userAvatar: review.userAvatar,
    );
    await _firestore.collection('reviews').add(reviewModel.toJson());
    
    // Update hospital average rating (optional but recommended for performance)
    // For now we'll calculate it on the fly or just add it here
  }

  @override
  Future<double> getAverageRating(String hospitalId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('hospitalId', isEqualTo: hospitalId)
        .get();
    
    if (snapshot.docs.isEmpty) return 0.0;
    
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['rating'] as num).toDouble();
    }
    return total / snapshot.docs.length;
  }
}

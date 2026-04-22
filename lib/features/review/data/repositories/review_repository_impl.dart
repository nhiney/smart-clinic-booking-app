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
        .map((s) => s.docs.map((doc) => ReviewModel.fromJson(doc.data(), doc.id)).toList());
  }

  @override
  Stream<List<ReviewEntity>> getDoctorReviews(String doctorId) {
    return _firestore
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((doc) => ReviewModel.fromJson(doc.data(), doc.id)).toList());
  }

  @override
  Future<void> addReview(ReviewEntity review) async {
    final model = ReviewModel(
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
    final docRef = await _firestore.collection('reviews').add(model.toJson());

    // Update aggregate rating on hospital document
    await _updateAggregateRating(review.hospitalId, review.rating);

    // Update aggregate rating on doctor document if provided
    if (review.doctorId != null) {
      await _updateDoctorAggregateRating(review.doctorId!, review.rating);
    }

    // Store reverse index so user can check own reviews
    await _firestore
        .collection('users')
        .doc(review.userId)
        .collection('my_reviews')
        .doc(docRef.id)
        .set({
      'reviewId': docRef.id,
      'hospitalId': review.hospitalId,
      'doctorId': review.doctorId,
      'rating': review.rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<double> getAverageRating(String hospitalId) async {
    final doc = await _firestore.collection('hospitals').doc(hospitalId).get();
    if (doc.exists && doc.data()?['averageRating'] != null) {
      return (doc.data()!['averageRating'] as num).toDouble();
    }
    final snapshot = await _firestore.collection('reviews').where('hospitalId', isEqualTo: hospitalId).get();
    if (snapshot.docs.isEmpty) return 0.0;
    final total = snapshot.docs.fold<double>(0, (sum, d) => sum + (d.data()['rating'] as num).toDouble());
    return total / snapshot.docs.length;
  }

  @override
  Future<double> getDoctorAverageRating(String doctorId) async {
    final doc = await _firestore.collection('doctors').doc(doctorId).get();
    if (doc.exists && doc.data()?['averageRating'] != null) {
      return (doc.data()!['averageRating'] as num).toDouble();
    }
    final snapshot = await _firestore.collection('reviews').where('doctorId', isEqualTo: doctorId).get();
    if (snapshot.docs.isEmpty) return 0.0;
    final total = snapshot.docs.fold<double>(0, (sum, d) => sum + (d.data()['rating'] as num).toDouble());
    return total / snapshot.docs.length;
  }

  @override
  Future<bool> hasUserReviewed({required String userId, String? hospitalId, String? doctorId}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('reviews').where('userId', isEqualTo: userId);
    if (hospitalId != null) query = query.where('hospitalId', isEqualTo: hospitalId);
    if (doctorId != null) query = query.where('doctorId', isEqualTo: doctorId);
    final snapshot = await query.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> toggleHelpful(String reviewId, String userId) async {
    final ref = _firestore.collection('reviews').doc(reviewId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final List<dynamic> current = doc.data()?['helpfulByUserIds'] ?? [];
    if (current.contains(userId)) {
      await ref.update({
        'helpfulByUserIds': FieldValue.arrayRemove([userId]),
        'helpfulCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'helpfulByUserIds': FieldValue.arrayUnion([userId]),
        'helpfulCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Future<List<ReviewEntity>> getUserReviews(String userId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromJson(doc.data(), doc.id)).toList();
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Future<void> _updateAggregateRating(String hospitalId, double newRating) async {
    final ref = _firestore.collection('hospitals').doc(hospitalId);
    await _firestore.runTransaction((txn) async {
      final doc = await txn.get(ref);
      if (!doc.exists) return;
      final count = (doc.data()?['reviewCount'] as num?)?.toInt() ?? 0;
      final avg = (doc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
      final newCount = count + 1;
      final newAvg = ((avg * count) + newRating) / newCount;
      txn.update(ref, {'averageRating': newAvg, 'reviewCount': newCount});
    });
  }

  Future<void> _updateDoctorAggregateRating(String doctorId, double newRating) async {
    final ref = _firestore.collection('doctors').doc(doctorId);
    await _firestore.runTransaction((txn) async {
      final doc = await txn.get(ref);
      if (!doc.exists) return;
      final count = (doc.data()?['reviewCount'] as num?)?.toInt() ?? 0;
      final avg = (doc.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
      final newCount = count + 1;
      final newAvg = ((avg * count) + newRating) / newCount;
      txn.update(ref, {'averageRating': newAvg, 'reviewCount': newCount});
    });
  }
}

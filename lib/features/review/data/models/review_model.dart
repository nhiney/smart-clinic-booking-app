import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/review/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.hospitalId,
    super.doctorId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.userName,
    super.userAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      hospitalId: json['hospitalId'] as String? ?? '',
      doctorId: json['doctorId'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'hospitalId': hospitalId,
      'doctorId': doctorId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'userName': userName,
      'userAvatar': userAvatar,
    };
  }
}

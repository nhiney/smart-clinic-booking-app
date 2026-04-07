import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userId;
  final String hospitalId;
  final String? doctorId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.hospitalId,
    this.doctorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  @override
  List<Object?> get props => [id, userId, hospitalId, doctorId, rating, comment, createdAt, userName, userAvatar];
}

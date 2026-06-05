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

  final int helpfulCount;
  final List<String> helpfulByUserIds;
  final String? doctorResponse;
  final DateTime? doctorResponseAt;

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
    this.helpfulCount = 0,
    this.helpfulByUserIds = const [],
    this.doctorResponse,
    this.doctorResponseAt,
  });

  bool isHelpfulFor(String uid) => helpfulByUserIds.contains(uid);

  @override
  List<Object?> get props => [id, userId, hospitalId, doctorId, rating, comment, createdAt, doctorResponse, doctorResponseAt];
}

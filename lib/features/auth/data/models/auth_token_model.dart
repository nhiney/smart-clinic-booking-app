import 'package:equatable/equatable.dart';

/// Model đại diện cho cặp token xác thực.
///
/// Sử dụng cho:
/// - Firebase ID Token (access token)
/// - Firebase Refresh Token
/// - Custom backend JWT (nếu mở rộng)
class AuthTokenModel extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String userId;

  const AuthTokenModel({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  /// Token đã hết hạn chưa (có buffer 5 phút).
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

  /// Token còn bao lâu nữa mới hết hạn.
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 1)),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'userId': userId,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, userId];
}

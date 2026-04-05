import 'package:equatable/equatable.dart';

/// Represents a health news article.
class HealthArticle extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String? articleUrl;

  const HealthArticle({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.articleUrl,
  });

  @override
  List<Object?> get props => [id, title, source, publishedAt];
}

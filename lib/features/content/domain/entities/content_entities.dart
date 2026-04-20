import 'package:equatable/equatable.dart';

class HealthLibraryArticle extends Equatable {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final List<String> tags;
  final DateTime publishedAt;
  final bool isBookmarked;

  const HealthLibraryArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    this.tags = const [],
    required this.publishedAt,
    this.isBookmarked = false,
  });

  HealthLibraryArticle copyWith({bool? isBookmarked}) => HealthLibraryArticle(
        id: id,
        title: title,
        content: content,
        category: category,
        imageUrl: imageUrl,
        tags: tags,
        publishedAt: publishedAt,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  factory HealthLibraryArticle.fromJson(Map<String, dynamic> json) {
    return HealthLibraryArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      publishedAt: json['publishedAt'] is String
          ? DateTime.parse(json['publishedAt'])
          : (json['publishedAt'] as dynamic).toDate(),
    );
  }

  @override
  List<Object?> get props => [id, title, category, isBookmarked];
}

class ServicePrice extends Equatable {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;

  const ServicePrice({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, category, price];
}

class Survey extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<SurveyOption> options;
  final Map<String, int> results; // optionId -> count

  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.results,
  });

  @override
  List<Object?> get props => [id, title, options, results];
}

class SurveyOption extends Equatable {
  final String id;
  final String text;

  const SurveyOption({required this.id, required this.text});

  @override
  List<Object?> get props => [id, text];
}

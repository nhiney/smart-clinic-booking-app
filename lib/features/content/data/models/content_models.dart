import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';

class ServicePriceModel extends ServicePrice {
  const ServicePriceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    super.description,
  });

  factory ServicePriceModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ServicePriceModel(
      id: id,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
    };
  }
}

class SurveyModel extends Survey {
  const SurveyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.options,
    required super.results,
  });

  factory SurveyModel.fromFirestore(Map<String, dynamic> json, String id) {
    final options = (json['options'] as List).map((o) => SurveyOption(
      id: o['id'] as String,
      text: o['text'] as String,
    )).toList();
    
    final resultsRaw = json['results'] as Map<String, dynamic>? ?? {};
    final results = resultsRaw.map((key, value) => MapEntry(key, value as int));

    return SurveyModel(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      options: options,
      results: results,
    );
  }
}

class HealthArticleCacheModel extends HealthArticle {
  const HealthArticleCacheModel({
    required super.id,
    required super.title,
    required super.summary,
    super.imageUrl,
    required super.source,
    required super.publishedAt,
    super.articleUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'articleUrl': articleUrl,
    };
  }

  factory HealthArticleCacheModel.fromJson(Map<String, dynamic> json) {
    return HealthArticleCacheModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      articleUrl: json['articleUrl'] as String?,
    );
  }
}

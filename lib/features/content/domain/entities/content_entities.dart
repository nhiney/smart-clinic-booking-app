import 'package:equatable/equatable.dart';

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

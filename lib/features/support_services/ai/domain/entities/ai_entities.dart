import 'package:equatable/equatable.dart';

/// Domain entity for an AI chat message.
class AiMessage extends Equatable {
  final String id;
  final String content;
  final AiMessageRole role;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, content, role, timestamp];
}

enum AiMessageRole { user, assistant }

/// Domain entity for symptom analysis result.
class SymptomAnalysis extends Equatable {
  final String summary;
  final List<String> possibleConditions;
  final String urgencyLevel;
  final List<String> recommendedActions;

  const SymptomAnalysis({
    required this.summary,
    required this.possibleConditions,
    required this.urgencyLevel,
    required this.recommendedActions,
  });

  @override
  List<Object?> get props => [summary, possibleConditions, urgencyLevel, recommendedActions];
}

/// Domain entity for doctor recommendation by AI.
class DoctorRecommendation extends Equatable {
  final String specialty;
  final String reason;
  final String urgency;

  const DoctorRecommendation({
    required this.specialty,
    required this.reason,
    required this.urgency,
  });

  @override
  List<Object?> get props => [specialty, reason, urgency];
}

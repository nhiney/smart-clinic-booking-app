import '../entities/ai_entities.dart';

/// Clean abstraction for any AI provider.
/// Swap MockAIService for OpenAIService without changing any calling code.
abstract class AiService {
  /// Generates a conversational response given a message and conversation history.
  Future<AiMessage> generateResponse({
    required String message,
    required List<AiMessage> history,
    String? userContext,
  });

  /// Analyzes symptom descriptions and returns structured analysis.
  Future<SymptomAnalysis> analyzeSymptoms(List<String> symptoms);

  /// Recommends medical specialties based on symptoms or user query.
  Future<DoctorRecommendation> recommendDoctor(String query);
}

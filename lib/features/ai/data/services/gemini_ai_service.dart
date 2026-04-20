import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/services/ai_service.dart';
import 'package:uuid/uuid.dart';

/// Real Gemini AI service using Google Generative AI SDK (free tier).
/// Model: gemini-2.0-flash — 15 RPM, 1500 req/day, 1M tokens/day — all free.
/// API key stored in environment; pass via --dart-define=GEMINI_API_KEY=...
class GeminiAiService implements AiService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const _uuid = Uuid();

  late final GenerativeModel _chat;
  late final GenerativeModel _analysis;

  GeminiAiService() {
    _chat = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 512, temperature: 0.7),
      systemInstruction: Content.text(
        'You are ICare, a compassionate healthcare assistant for a Vietnamese clinic app. '
        'Answer in the same language as the user (Vietnamese or English). '
        'Never diagnose definitively — always recommend consulting a doctor for serious symptoms. '
        'Be concise (under 150 words per response). '
        'Focus on: appointment booking, medication reminders, symptom triage, doctor recommendations.',
      ),
    );
    _analysis = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 300, temperature: 0.3),
    );
  }

  @override
  Future<AiMessage> generateResponse({
    required String message,
    required List<AiMessage> history,
    String? userContext,
  }) async {
    if (_apiKey.isEmpty) {
      return _fallback(message);
    }
    try {
      final geminiHistory = history.map((m) {
        final role = m.role == AiMessageRole.user ? 'user' : 'model';
        return Content(role, [TextPart(m.content)]);
      }).toList();

      final session = _chat.startChat(history: geminiHistory);
      final contextPrefix = userContext != null ? '[Context: $userContext]\n' : '';
      final response = await session.sendMessage(Content.text('$contextPrefix$message'));
      final text = response.text ?? 'I could not generate a response. Please try again.';

      return AiMessage(
        id: _uuid.v4(),
        content: text,
        role: AiMessageRole.assistant,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return _fallback(message);
    }
  }

  @override
  Future<SymptomAnalysis> analyzeSymptoms(List<String> symptoms) async {
    if (_apiKey.isEmpty || symptoms.isEmpty) {
      return _mockSymptomAnalysis(symptoms);
    }
    try {
      final prompt = '''
Analyze these health symptoms: ${symptoms.join(', ')}.
Respond ONLY in this JSON format (no markdown):
{
  "summary": "brief summary",
  "possibleConditions": ["condition1", "condition2", "condition3"],
  "urgencyLevel": "low|medium|high",
  "recommendedActions": ["action1", "action2", "action3", "action4"]
}
''';
      final response = await _analysis.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parseSymptomJson(text, symptoms);
    } catch (_) {
      return _mockSymptomAnalysis(symptoms);
    }
  }

  @override
  Future<DoctorRecommendation> recommendDoctor(String query) async {
    if (_apiKey.isEmpty) return _mockDoctorRecommendation(query);
    try {
      final prompt = '''
Based on this health query: "$query"
Recommend a medical specialty. Respond ONLY in JSON (no markdown):
{
  "specialty": "specialty name",
  "reason": "brief reason",
  "urgency": "low|medium|high"
}
''';
      final response = await _analysis.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parseDoctorJson(text, query);
    } catch (_) {
      return _mockDoctorRecommendation(query);
    }
  }

  // ─── PARSERS ──────────────────────────────────────────────────────────────

  SymptomAnalysis _parseSymptomJson(String text, List<String> symptoms) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return _mockSymptomAnalysis(symptoms);
      final cleaned = text.substring(start, end + 1);
      // Simple manual parse to avoid json_serializable dependency
      return SymptomAnalysis(
        summary: _extractStr(cleaned, 'summary'),
        possibleConditions: _extractList(cleaned, 'possibleConditions'),
        urgencyLevel: _extractStr(cleaned, 'urgencyLevel'),
        recommendedActions: _extractList(cleaned, 'recommendedActions'),
      );
    } catch (_) {
      return _mockSymptomAnalysis(symptoms);
    }
  }

  DoctorRecommendation _parseDoctorJson(String text, String query) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return _mockDoctorRecommendation(query);
      final cleaned = text.substring(start, end + 1);
      return DoctorRecommendation(
        specialty: _extractStr(cleaned, 'specialty'),
        reason: _extractStr(cleaned, 'reason'),
        urgency: _extractStr(cleaned, 'urgency'),
      );
    } catch (_) {
      return _mockDoctorRecommendation(query);
    }
  }

  String _extractStr(String json, String key) {
    final pattern = RegExp('"$key"\\s*:\\s*"([^"]*)"');
    return pattern.firstMatch(json)?.group(1) ?? '';
  }

  List<String> _extractList(String json, String key) {
    final pattern = RegExp('"$key"\\s*:\\s*\\[([^\\]]*)\\]');
    final match = pattern.firstMatch(json)?.group(1) ?? '';
    return RegExp('"([^"]*)"').allMatches(match).map((m) => m.group(1) ?? '').where((s) => s.isNotEmpty).toList();
  }

  // ─── FALLBACKS ────────────────────────────────────────────────────────────

  AiMessage _fallback(String message) {
    final lower = message.toLowerCase();
    String content;
    if (lower.contains('đau') || lower.contains('pain') || lower.contains('hurt')) {
      content = 'Tôi hiểu bạn đang không khỏe. Hãy mô tả thêm triệu chứng để tôi có thể tư vấn tốt hơn, hoặc đặt lịch khám với bác sĩ.';
    } else if (lower.contains('thuốc') || lower.contains('medicine') || lower.contains('medication')) {
      content = 'Về thuốc, bạn nên uống đúng liều và đúng giờ. Kiểm tra lịch thuốc trong mục "Nhắc uống thuốc".';
    } else if (lower.contains('lịch') || lower.contains('appointment') || lower.contains('bác sĩ')) {
      content = 'Để đặt lịch khám, vào mục "Đặt lịch" và chọn bác sĩ phù hợp. Tôi có thể gợi ý chuyên khoa nếu bạn mô tả triệu chứng.';
    } else {
      content = 'Xin chào! Tôi là trợ lý ICare. Hỏi tôi về triệu chứng, lịch khám, hoặc thuốc. Tôi sẵn sàng hỗ trợ bạn!';
    }
    return AiMessage(id: _uuid.v4(), content: content, role: AiMessageRole.assistant, timestamp: DateTime.now());
  }

  SymptomAnalysis _mockSymptomAnalysis(List<String> symptoms) {
    return SymptomAnalysis(
      summary: 'Based on ${symptoms.length} symptom(s), this may be a mild condition.',
      possibleConditions: ['Common cold', 'Stress-related fatigue', 'Insufficient sleep'],
      urgencyLevel: 'low',
      recommendedActions: ['Rest adequately', 'Stay hydrated', 'Monitor symptoms for 2-3 days', 'See a doctor if no improvement'],
    );
  }

  DoctorRecommendation _mockDoctorRecommendation(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('tim') || lower.contains('heart') || lower.contains('ngực') || lower.contains('chest')) {
      return const DoctorRecommendation(specialty: 'Cardiology', reason: 'Symptoms related to heart or chest', urgency: 'high');
    }
    if (lower.contains('da') || lower.contains('skin') || lower.contains('mẩn') || lower.contains('rash')) {
      return const DoctorRecommendation(specialty: 'Dermatology', reason: 'Skin-related symptoms', urgency: 'low');
    }
    return const DoctorRecommendation(specialty: 'General Practice', reason: 'General health check-up recommended', urgency: 'low');
  }
}

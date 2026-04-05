import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/services/ai_service.dart';

/// Development-mode mock AI service.
/// Returns realistic-sounding Vietnamese healthcare responses.
/// Replace with OpenAIService in production by swapping the binding in injection.dart.
class MockAiService implements AiService {
  static const _uuid = Uuid();

  // Simple rule-based response map for demo
  static const Map<String, String> _responseMap = {
    'đau đầu': 'Đau đầu có thể do nhiều nguyên nhân như căng thẳng, mất ngủ, hoặc thiếu nước. Bạn nên nghỉ ngơi, uống đủ nước và theo dõi tần suất. Nếu đau đầu kéo dài hơn 3 ngày hoặc đau dữ dội, hãy đến gặp bác sĩ.',
    'sốt': 'Sốt là phản ứng tự nhiên của cơ thể chống lại nhiễm trùng. Nếu sốt trên 38.5°C, hãy uống thuốc hạ sốt và giữ đủ nước. Nên gặp bác sĩ nếu sốt kéo dài hơn 3 ngày.',
    'tim mạch': 'Tôi gợi ý bạn nên gặp bác sĩ chuyên khoa Tim mạch. Triệu chứng như đau ngực, khó thở, hoặc hồi hộp cần được đánh giá chuyên sâu.',
    'thuốc': 'Dựa trên lịch uống thuốc của bạn, bạn còn 2 loại thuốc chưa uống hôm nay: Vitamin D3 lúc 12:00 và Omega-3 lúc 20:00.',
    'xét nghiệm': 'Kết quả xét nghiệm gần nhất của bạn cho thấy chỉ số đường huyết bình thường (95 mg/dL). Bạn có muốn xем chi tiết không?',
  };

  static const String _defaultResponse =
      'Xin chào! Tôi là trợ lý AI ICare. Tôi có thể giúp bạn tìm bác sĩ, kiểm tra lịch thuốc, phân tích triệu chứng cơ bản, hoặc giải đáp câu hỏi sức khỏe. Bạn cần hỗ trợ gì?';

  @override
  Future<AiMessage> generateResponse({
    required String message,
    required List<AiMessage> history,
    String? userContext,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerMsg = message.toLowerCase();
    String responseContent = _defaultResponse;

    for (final entry in _responseMap.entries) {
      if (lowerMsg.contains(entry.key)) {
        responseContent = entry.value;
        break;
      }
    }

    return AiMessage(
      id: _uuid.v4(),
      content: responseContent,
      role: AiMessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SymptomAnalysis> analyzeSymptoms(List<String> symptoms) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return SymptomAnalysis(
      summary: 'Dựa trên ${symptoms.length} triệu chứng bạn mô tả, có thể đây là tình trạng nhẹ.',
      possibleConditions: ['Cảm cúm thông thường', 'Mệt mỏi do stress', 'Thiếu ngủ'],
      urgencyLevel: 'low',
      recommendedActions: [
        'Nghỉ ngơi đầy đủ',
        'Uống nhiều nước',
        'Theo dõi triệu chứng trong 2-3 ngày',
        'Gặp bác sĩ nếu tình trạng không cải thiện',
      ],
    );
  }

  @override
  Future<DoctorRecommendation> recommendDoctor(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = query.toLowerCase();
    if (lower.contains('tim') || lower.contains('ngực')) {
      return const DoctorRecommendation(
        specialty: 'Tim mạch',
        reason: 'Triệu chứng của bạn liên quan đến tim mạch',
        urgency: 'medium',
      );
    }
    if (lower.contains('da') || lower.contains('mẩn')) {
      return const DoctorRecommendation(
        specialty: 'Da liễu',
        reason: 'Triệu chứng liên quan đến da',
        urgency: 'low',
      );
    }
    return const DoctorRecommendation(
      specialty: 'Nội khoa',
      reason: 'Khám tổng quát để đánh giá sức khỏe toàn diện',
      urgency: 'low',
    );
  }
}

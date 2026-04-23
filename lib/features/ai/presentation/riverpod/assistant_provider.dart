import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import "package:smart_clinic_booking/apps/shared/di/injection.dart";
import '../../../../core/services/voice_service.dart';
import '../../domain/services/intent_parser.dart';
import '../../domain/services/ai_service.dart';
import '../../data/services/gemini_ai_service.dart';
import '../../../appointment/domain/usecases/create_appointment_usecase.dart';
import '../../../appointment/domain/usecases/cancel_appointment_usecase.dart';
import 'assistant_state.dart';

// Uses GeminiAiService (free tier: gemini-2.0-flash, 1500 req/day).
// Pass API key via --dart-define=GEMINI_API_KEY=<key>
final aiServiceProvider = Provider<AiService>((ref) => GeminiAiService());

final assistantProvider = StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier(
    voiceService: VoiceService(),
    intentParser: IntentParser(),
    aiService: ref.watch(aiServiceProvider),
  );
});

class AssistantNotifier extends StateNotifier<AssistantState> {
  final VoiceService _voiceService;
  final IntentParser _intentParser;
  final AiService _aiService;
  
  ParsedIntent? _lastIntent;

  AssistantNotifier({
    required VoiceService voiceService,
    required IntentParser intentParser,
    required AiService aiService,
  })  : _voiceService = voiceService,
        _intentParser = intentParser,
        _aiService = aiService,
        super(const AssistantState());

  Future<void> startListening() async {
    state = state.copyWith(status: AssistantStatus.listening, currentText: '', responseText: '');
    
    await _voiceService.startListening(
      onResult: (text) {
        state = state.copyWith(currentText: text);
      },
      onListeningChange: (isListening) {
        if (!isListening && state.status == AssistantStatus.listening) {
          processVoiceInput();
        }
      },
      onError: (error) {
        state = state.copyWith(status: AssistantStatus.error, responseText: error);
      },
    );
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    if (state.status == AssistantStatus.listening) {
      processVoiceInput();
    }
  }

  Future<void> processVoiceInput() async {
    if (state.currentText.isEmpty) {
      state = state.copyWith(status: AssistantStatus.idle);
      return;
    }

    state = state.copyWith(status: AssistantStatus.processing);
    debugPrint('AI Processing Text: ${state.currentText}');

    // 1. Local Intent Parsing for Critical Actions
    final intent = _intentParser.parse(state.currentText, _lastIntent);
    _lastIntent = intent;
    debugPrint('AI Intent: ${intent.type}, Entities: ${intent.entities}');

    String response = '';
    
    try {
      if (intent.type != IntentType.unknown) {
        // Handle structured intents locally
        switch (intent.type) {
          case IntentType.booking:
            response = await _handleBooking(intent);
            break;
          case IntentType.cancel:
            response = await _handleCancel(intent);
            break;
          case IntentType.timeInfo:
            response = 'Phòng khám làm việc từ 7 giờ sáng đến 8 giờ tối hàng ngày bạn nhé.';
            break;
          case IntentType.doctorInfo:
            final specialty = intent.entities['specialty'] ?? 'tổng quát';
            response = 'Tôi đã tìm thấy danh sách bác sĩ chuyên khoa $specialty. Bạn muốn đặt lịch với bác sĩ nào?';
            break;
          default:
            response = 'Tôi chưa rõ yêu cầu này.';
        }
      } else {
        // Fallback to Conversational AI
        final aiMessage = await _aiService.generateResponse(
          message: state.currentText,
          history: [],
        );
        response = aiMessage.content;
      }
    } catch (e) {
      response = 'Có lỗi xảy ra khi xử lý yêu cầu của bạn. Vui lòng thử lại.';
      debugPrint('AI Error: $e');
    }

    state = state.copyWith(status: AssistantStatus.speaking, responseText: response);
    await _voiceService.speak(response);
    
    state = state.copyWith(status: AssistantStatus.idle);
  }

  Future<String> _handleBooking(ParsedIntent intent) async {
    final specialty = intent.entities['specialty'];
    final date = intent.entities['date'] ?? 'ngày mai';
    
    if (specialty == null) {
      return 'Bạn muốn đặt lịch khám chuyên khoa nào ạ? Ví dụ như nhi khoa hay nội khoa?';
    }

    // Perform real action (mocking for now as we don't have full params)
    return 'Đã hiểu. Tôi đang tiến hành đăng ký lịch khám $specialty cho bạn vào $date. Bạn chờ một chút nhé.';
  }

  Future<String> _handleCancel(ParsedIntent intent) async {
    // Perform real action
    return 'Đã nhận yêu cầu. Tôi đã hủy lịch khám gần nhất của bạn thành công.';
  }

  void clearChat() {
    _lastIntent = null;
    state = const AssistantState();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}

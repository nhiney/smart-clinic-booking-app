import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/core/services/voice_service.dart';
import '../../domain/services/intent_parser.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/entities/ai_entities.dart';
import '../../data/services/gemini_ai_service.dart';
import './assistant_state.dart';

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
  bool _processingLock = false;

  AssistantNotifier({
    required VoiceService voiceService,
    required IntentParser intentParser,
    required AiService aiService,
  })  : _voiceService = voiceService,
        _intentParser = intentParser,
        _aiService = aiService,
        super(const AssistantState());

  VoiceService get voiceService => _voiceService;

  Future<void> startListening() async {
    if (state.status == AssistantStatus.processing || state.status == AssistantStatus.speaking) {
      return;
    }
    _processingLock = false;
    state = state.copyWith(
      status: AssistantStatus.listening,
      currentText: '',
      responseText: '',
      clearPendingBooking: true,
    );

    await _voiceService.startListening(
      onResult: (text) {
        state = state.copyWith(currentText: text);
      },
      onListeningChange: (isListening) {
        if (!isListening && state.status == AssistantStatus.listening) {
          _triggerProcess();
        }
      },
      onError: (error) {
        state = state.copyWith(status: AssistantStatus.error, responseText: error);
      },
    );
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    // finalResult callback may have already triggered _triggerProcess().
    // Only call here if state is still listening (callback didn't fire yet).
    if (state.status == AssistantStatus.listening) {
      _triggerProcess();
    }
  }

  void _triggerProcess() {
    if (_processingLock) return;
    _processingLock = true;
    processVoiceInput();
  }

  Future<void> processVoiceInput() async {
    if (state.currentText.isEmpty) {
      state = state.copyWith(status: AssistantStatus.idle);
      return;
    }

    state = state.copyWith(status: AssistantStatus.processing);
    debugPrint('AI Processing Text: ${state.currentText}');

    final userInput = state.currentText;
    final intent = _intentParser.parse(userInput, _lastIntent);
    _lastIntent = intent;
    debugPrint('AI Intent: ${intent.type}, Entities: ${intent.entities}');

    String response = '';
    BookingIntentData? pendingBooking;

    try {
      if (intent.type != IntentType.unknown) {
        switch (intent.type) {
          case IntentType.booking:
            final result = await _handleBooking(intent);
            response = result.$1;
            pendingBooking = result.$2;
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
        // Build history for context
        final history = state.history
            .expand((t) => [
                  AiMessage(id: '', content: t.userText, role: AiMessageRole.user, timestamp: DateTime.now()),
                  AiMessage(id: '', content: t.aiText, role: AiMessageRole.assistant, timestamp: DateTime.now()),
                ])
            .toList();

        final aiMessage = await _aiService.generateResponse(
          message: userInput,
          history: history,
        );
        response = aiMessage.content;
      }
    } catch (e) {
      response = 'Có lỗi xảy ra khi xử lý yêu cầu của bạn. Vui lòng thử lại.';
      debugPrint('AI Error: $e');
    }

    final newHistory = [
      ...state.history,
      ConversationTurn(userText: userInput, aiText: response),
    ];

    state = state.copyWith(
      status: AssistantStatus.speaking,
      responseText: response,
      history: newHistory.length > 10 ? newHistory.sublist(newHistory.length - 10) : newHistory,
      pendingBooking: pendingBooking,
    );

    await _voiceService.speak(response);
    _processingLock = false;
    state = state.copyWith(status: AssistantStatus.idle);
  }

  /// Returns (voiceResponse, bookingData). bookingData is null when info is incomplete.
  Future<(String, BookingIntentData?)> _handleBooking(ParsedIntent intent) async {
    final specialty = intent.entities['specialty'];
    final date = intent.entities['date'] ?? 'ngày mai';
    final timeSlot = intent.entities['time_slot'];

    if (specialty == null) {
      return ('Bạn muốn đặt lịch khám chuyên khoa nào ạ? Ví dụ như nhi khoa hay nội khoa?', null);
    }

    final timeText = timeSlot != null ? ' $timeSlot' : '';
    final bookingData = BookingIntentData(specialty: specialty, date: date, timeSlot: timeSlot);
    return (
      'Được rồi! Tôi nhận yêu cầu đặt lịch khám $specialty vào $date$timeText. Hãy xác nhận thông tin để hoàn tất nhé.',
      bookingData,
    );
  }

  Future<String> _handleCancel(ParsedIntent intent) async {
    return 'Đã nhận yêu cầu hủy lịch. Vui lòng vào mục Lịch hẹn để xác nhận hủy.';
  }

  void clearPendingBooking() {
    state = state.copyWith(clearPendingBooking: true);
  }

  /// Bơm trực tiếp một câu đã nhận dạng vào pipeline xử lý (phân tích ý định →
  /// phản hồi → popup đặt lịch), bỏ qua bước thu âm. Dùng cho integration test
  /// và chế độ gõ thay vì nói.
  @visibleForTesting
  Future<void> injectTranscript(String text) async {
    _processingLock = false;
    state = state.copyWith(
      status: AssistantStatus.listening,
      currentText: text,
      clearPendingBooking: true,
    );
    await processVoiceInput();
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

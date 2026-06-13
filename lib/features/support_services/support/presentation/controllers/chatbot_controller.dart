import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/domain/entities/ai_entities.dart';
import '../../../ai/domain/services/ai_service.dart';
import '../../../ai/presentation/riverpod/assistant_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatbotState({this.messages = const [], this.isTyping = false});

  ChatbotState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final AiService _aiService;

  ChatbotNotifier(this._aiService) : super(ChatbotState()) {
    // Initial welcome message
    _addBotMessage('Xin chào! Tôi là trợ lý ảo ICare. Tôi có thể giúp gì cho bạn?');
  }

  static const String _systemContext =
      'Bạn là trợ lý ảo của ứng dụng đặt khám ICare. Trả lời ngắn gọn, thân thiện '
      'bằng tiếng Việt về: đặt/hủy lịch khám, đơn thuốc, bảng giá dịch vụ, hồ sơ bệnh án '
      'và cách dùng ứng dụng. Không đưa ra chẩn đoán y khoa thay bác sĩ.';

  void _addBotMessage(String text) {
    state = state.copyWith(
      messages: [ChatMessage(text: text, isUser: false), ...state.messages],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Build conversation history (oldest first) BEFORE adding the new message.
    final history = state.messages.reversed
        .map((m) => AiMessage(
              id: m.timestamp.microsecondsSinceEpoch.toString(),
              content: m.text,
              role: m.isUser ? AiMessageRole.user : AiMessageRole.assistant,
              timestamp: m.timestamp,
            ))
        .toList();

    // Add user message
    state = state.copyWith(
      messages: [ChatMessage(text: text, isUser: true), ...state.messages],
      isTyping: true,
    );

    String response;
    try {
      final reply = await _aiService.generateResponse(
        message: text,
        history: history,
        userContext: _systemContext,
      );
      response = reply.content.trim().isEmpty
          ? _getRuleBasedResponse(text)
          : reply.content.trim();
    } catch (_) {
      // Fall back to rule-based answers if the AI service is unavailable.
      response = _getRuleBasedResponse(text);
    }

    state = state.copyWith(isTyping: false);
    _addBotMessage(response);
  }

  String _getRuleBasedResponse(String text) {
    final t = text.toLowerCase();
    
    if (t.contains('đặt lịch') || t.contains('hẹn')) {
      return 'Để đặt lịch khám, bạn vui lòng chọn nút "Đặt lịch khám" tại màn hình chính hoặc tìm kiếm bác sĩ chuyên khoa phù hợp.';
    }
    if (t.contains('hủy') || t.contains('đổi')) {
      return 'Bạn có thể quản lý và hủy lịch hẹn trong phần "Lịch hẹn của tôi". Lưu ý nên hủy trước ít nhất 2 tiếng.';
    }
    if (t.contains('thuốc') || t.contains('đơn')) {
      return 'Đơn thuốc của bạn được lưu trong mục "Đơn thuốc & Nhắc nhở". Bạn sẽ nhận được thông báo khi đến giờ uống thuốc.';
    }
    if (t.contains('giá') || t.contains('phí')) {
      return 'Chi phí khám bệnh tùy thuộc vào chuyên khoa và bác sĩ. Bạn có thể xem bảng giá chi tiết trong mục "Dịch vụ & Bảng giá".';
    }
    if (t.contains('liên hệ') || t.contains('tổng đài') || t.contains('hotline')) {
      return 'Bạn có thể gọi số hotline 1900xxxx để được hỗ trợ trực tiếp từ nhân viên y tế.';
    }
    
    return 'Xin lỗi, tôi chưa hiểu rõ yêu cầu của bạn. Bạn có thể hỏi về: Đặt lịch khám, Đơn thuốc, hoặc Bảng giá dịch vụ.';
  }
}

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref.watch(aiServiceProvider));
});

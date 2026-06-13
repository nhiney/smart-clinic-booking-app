import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/identity/auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/ai_entities.dart';
import '../../data/services/gemini_ai_service.dart';
import './voice_assistant_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

final _uuid = const Uuid();

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _gemini = GeminiAiService();
  final _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final List<AiMessage> _messages = [];

  bool _isLoading = false;
  bool _isListening = false;
  String? _speakingMessageId;

  @override
  void initState() {
    super.initState();
    _addWelcome();
    _initTts();
  }

  void _addWelcome() {
    _messages.add(AiMessage(
      id: _uuid.v4(),
      content: 'Xin chào! Tôi là trợ lý AI ICare 🩺\nTôi có thể giúp bạn:\n• Phân tích triệu chứng\n• Gợi ý chuyên khoa bác sĩ\n• Tư vấn về thuốc và lịch khám\n\nBạn cần hỗ trợ gì hôm nay?',
      role: AiMessageRole.assistant,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speakingMessageId = null);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    final userMsg = AiMessage(
      id: _uuid.v4(),
      content: text.trim(),
      role: AiMessageRole.user,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    final auth = legacy.Provider.of<AuthController>(context, listen: false);
    final userContext = auth.currentUser != null ? 'Patient: ${auth.currentUser!.name}' : null;

    try {
      final history = _messages
          .where((m) => m.role == AiMessageRole.user || m.role == AiMessageRole.assistant)
          .take(10)
          .toList();
      final response = await _gemini.generateResponse(
        message: text.trim(),
        history: history,
        userContext: userContext,
      );
      setState(() => _messages.add(response));
    } catch (_) {
      setState(() => _messages.add(AiMessage(
            id: _uuid.v4(),
            content: 'Xin lỗi, tôi gặp sự cố. Vui lòng thử lại sau.',
            role: AiMessageRole.assistant,
            timestamp: DateTime.now(),
          )));
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _toggleSpeakMessage(AiMessage msg) async {
    if (_speakingMessageId == msg.id) {
      await _tts.stop();
      setState(() => _speakingMessageId = null);
    } else {
      await _tts.stop();
      setState(() => _speakingMessageId = msg.id);
      await _tts.speak(msg.content);
    }
  }

  Future<void> _startVoiceInput() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) return;

    final initialized = await _speech.initialize();
    if (!initialized) return;

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'vi_VN',
      onResult: (val) {
        if (val.recognizedWords.isNotEmpty) {
          _textController.text = val.recognizedWords;
        }
        if (val.finalResult) {
          setState(() => _isListening = false);
          if (val.recognizedWords.isNotEmpty) {
            _sendMessage(val.recognizedWords);
          }
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  Future<void> _stopVoiceInput() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: BrandedAppBar(
        title: 'AI Health Assistant',
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
            ),
            tooltip: 'Trợ lý giọng nói',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {
              _messages.clear();
              _addWelcome();
            }),
            tooltip: 'Xóa chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isLoading && i == _messages.length) return _TypingIndicator();
                final msg = _messages[i];
                return _MessageBubble(
                  message: msg,
                  isSpeaking: _speakingMessageId == msg.id,
                  onSpeak: msg.role == AiMessageRole.assistant
                      ? () => _toggleSpeakMessage(msg)
                      : null,
                );
              },
            ),
          ),
          _buildQuickSuggestions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = ['Tôi bị đau đầu', 'Gợi ý bác sĩ tim mạch', 'Nhắc uống thuốc', 'Đặt lịch khám'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(suggestions[i]),
          child: Chip(
            label: Text(suggestions[i], style: const TextStyle(fontSize: 12)),
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
            side: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: Colors.white,
      child: Row(
        children: [
          // Voice input button
          GestureDetector(
            onTapDown: (_) => _startVoiceInput(),
            onTapUp: (_) => _stopVoiceInput(),
            onTapCancel: () => _stopVoiceInput(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.redAccent
                    : context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: _isListening ? Colors.white : context.colors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _isListening ? 'Đang nghe...' : 'Hỏi về sức khỏe...',
                filled: true,
                fillColor: const Color(0xFFF0F4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }
}

// ─── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

  const _MessageBubble({
    required this.message,
    required this.isSpeaking,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiMessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? context.colors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            if (onSpeak != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: GestureDetector(
                  onTap: onSpeak,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSpeaking ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSpeaking ? 'Dừng' : 'Đọc',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Typing Indicator ────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

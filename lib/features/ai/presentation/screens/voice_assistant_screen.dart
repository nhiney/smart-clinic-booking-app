import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/assistant_provider.dart';
import '../riverpod/assistant_state.dart';
import '../widgets/voice_booking_confirm_sheet.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<double>? _soundSub;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceService = ref.read(assistantProvider.notifier).voiceService;
      _soundSub = voiceService.soundLevelStream.listen((level) {
        if (mounted) setState(() => _soundLevel = level);
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _soundSub?.cancel();
    super.dispose();
  }

  void _showBookingSheet(BuildContext context, BookingIntentData data) {
    final notifier = ref.read(assistantProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceBookingConfirmSheet(
        data: data,
        onClose: notifier.clearPendingBooking,
      ),
    ).then((_) => notifier.clearPendingBooking());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    final notifier = ref.read(assistantProvider.notifier);

    // Show booking confirmation sheet when intent is detected.
    ref.listen<AssistantState>(assistantProvider, (prev, next) {
      if (next.pendingBooking != null && prev?.pendingBooking == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showBookingSheet(context, next.pendingBooking!);
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 10,
              right: 16,
              child: IconButton(
                onPressed: () {
                  notifier.stopListening();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, color: Colors.white70, size: 28),
              ),
            ),

            // Clear history button
            Positioned(
              top: 10,
              left: 16,
              child: IconButton(
                onPressed: notifier.clearChat,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white38, size: 24),
                tooltip: 'Xóa lịch sử',
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 60),

                // Conversation history
                Expanded(
                  child: _buildConversationHistory(state),
                ),

                // Current user speech
                _buildCurrentSpeechArea(state),

                const SizedBox(height: 20),

                // Waveform / animation
                _buildWaveform(state),

                const SizedBox(height: 24),

                // Mic button
                _buildMicButton(state, notifier),

                const SizedBox(height: 16),

                // Status label
                Text(
                  _getHelperText(state.status),
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHistory(AssistantState state) {
    if (state.history.isEmpty && state.responseText.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_none_rounded, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text(
              'Nhấn và giữ để nói\nTôi sẽ lắng nghe và trả lời',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 16, height: 1.6),
            ),
          ],
        ),
      );
    }

    final turns = state.history.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: turns.length + (state.responseText.isNotEmpty && state.status != AssistantStatus.idle ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < turns.length) {
          final turn = turns[i];
          return _ConversationTurnWidget(turn: turn);
        }
        // Latest AI response still in progress
        return _AiBubble(text: state.responseText, isAnimating: state.status == AssistantStatus.speaking);
      },
    );
  }

  Widget _buildCurrentSpeechArea(AssistantState state) {
    // Show error message when status is error.
    if (state.status == AssistantStatus.error && state.responseText.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                state.responseText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }
    if (state.currentText.isEmpty) return const SizedBox(height: 40);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: Text(
        state.currentText,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildWaveform(AssistantState state) {
    if (state.status == AssistantStatus.listening) {
      return _SoundWave(level: _soundLevel);
    }
    if (state.status == AssistantStatus.processing) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2.5),
      );
    }
    if (state.status == AssistantStatus.speaking) {
      return _SpeakingWave();
    }
    return const SizedBox(height: 40);
  }

  Widget _buildMicButton(AssistantState state, AssistantNotifier notifier) {
    final isListening = state.status == AssistantStatus.listening;
    final isError = state.status == AssistantStatus.error;
    final isBusy = state.status == AssistantStatus.processing || state.status == AssistantStatus.speaking;

    final color = isListening
        ? Colors.redAccent
        : isError
            ? Colors.orange
            : Colors.blueAccent;

    return GestureDetector(
      // Tap once to start, tap again to stop (or auto-stop after 2s pause).
      onTap: () {
        if (isListening) {
          notifier.stopListening();
        } else if (!isBusy) {
          notifier.startListening();
        }
      },
      // Also support press-and-hold for quick queries.
      onLongPressStart: (_) {
        if (!isBusy) notifier.startListening();
      },
      onLongPressEnd: (_) {
        if (isListening) notifier.stopListening();
      },
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = isListening ? (1.0 + _soundLevel * 0.3) : (isBusy ? 0.9 : 1.0);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isBusy ? Colors.grey.shade600 : color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isListening ? 0.5 : 0.3),
                    blurRadius: isListening ? 32 : 16,
                    spreadRadius: isListening ? 8 : 4,
                  ),
                ],
              ),
              child: Icon(
                isListening
                    ? Icons.stop_rounded
                    : isBusy
                        ? Icons.hourglass_top_rounded
                        : Icons.mic_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getHelperText(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.listening:
        return 'Đang lắng nghe... (nhấn để dừng)';
      case AssistantStatus.processing:
        return 'Đang xử lý...';
      case AssistantStatus.speaking:
        return 'Đang trả lời...';
      case AssistantStatus.error:
        return 'Có lỗi — nhấn mic để thử lại';
      default:
        return 'Nhấn mic để bắt đầu nói';
    }
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _ConversationTurnWidget extends StatelessWidget {
  final ConversationTurn turn;
  const _ConversationTurnWidget({required this.turn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User bubble (right)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, left: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(turn.userText, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
        // AI bubble (left)
        _AiBubble(text: turn.aiText, isAnimating: false),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  final bool isAnimating;
  const _AiBubble({required this.text, required this.isAnimating});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: isAnimating
            ? _TypingDots()
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
          final opacity = (offset < 0.5 ? offset * 2 : (1 - offset) * 2).clamp(0.3, 1.0);
          return Opacity(
            opacity: opacity,
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _SoundWave extends StatelessWidget {
  final double level;
  const _SoundWave({required this.level});

  @override
  Widget build(BuildContext context) {
    const barCount = 7;
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (i) {
          final center = barCount / 2;
          final distFromCenter = (i - center).abs() / center;
          final height = 8.0 + (1.0 - distFromCenter) * level * 32;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 5,
            height: height.clamp(6.0, 40.0),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.6 + level * 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _SpeakingWave extends StatefulWidget {
  @override
  State<_SpeakingWave> createState() => _SpeakingWaveState();
}

class _SpeakingWaveState extends State<_SpeakingWave> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    const barCount = 7;
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(barCount, (i) {
            final phase = (_ctrl.value * 2 * math.pi) + (i * math.pi / barCount);
            final height = 8.0 + math.sin(phase).abs() * 28;
            return Container(
              width: 5,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

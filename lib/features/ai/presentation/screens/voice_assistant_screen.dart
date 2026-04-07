import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../riverpod/assistant_provider.dart';
import '../riverpod/assistant_state.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantProvider);
    final notifier = ref.read(assistantProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 10,
              right: 16,
              child: IconButton(
                onPressed: () {
                  notifier.stopListening();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),

            Column(
              children: [
                const Spacer(flex: 2),
                
                // AI Response Area
                _buildResponseArea(state),
                
                const SizedBox(height: 30),
                
                // User Speech Real-time Text
                _buildRealtimeTextArea(state),
                  
                const Spacer(flex: 3),
                
                // Mic & Animation Area
                _buildMicSection(state, notifier),
                
                const SizedBox(height: 40),
                
                // Helper Text
                Text(
                  _getHelperText(state.status),
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseArea(AssistantState state) {
    String text = state.responseText.isNotEmpty ? state.responseText : 'Tôi có thể giúp gì cho bạn?';
    if (state.status == AssistantStatus.error) {
      text = state.responseText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          text,
          key: ValueKey(text),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: state.status == AssistantStatus.error ? Colors.redAccent : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeTextArea(AssistantState state) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      alignment: Alignment.center,
      child: state.currentText.isNotEmpty
          ? Text(
              state.currentText,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMicSection(AssistantState state, AssistantNotifier notifier) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: _buildAnimation(state.status),
        ),
          
        const SizedBox(height: 20),
        
        GestureDetector(
          onTapDown: (_) => notifier.startListening(),
          onTapUp: (_) => notifier.stopListening(),
          onTapCancel: () => notifier.stopListening(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: state.status == AssistantStatus.listening ? Colors.redAccent : Colors.blueAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (state.status == AssistantStatus.listening ? Colors.redAccent : Colors.blueAccent).withOpacity(0.4),
                  blurRadius: state.status == AssistantStatus.listening ? 30 : 15,
                  spreadRadius: state.status == AssistantStatus.listening ? 10 : 5,
                ),
              ],
            ),
            child: Icon(
              state.status == AssistantStatus.listening ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimation(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.listening:
        return Lottie.network(
          'https://lottie.host/08680604-006d-4691-9a6d-86e63949ba9b/YTYm0XQYvQ.json', // Modern voice wave
          fit: BoxFit.contain,
        );
      case AssistantStatus.processing:
        return const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 3),
          ),
        );
      case AssistantStatus.speaking:
        return Lottie.network(
          'https://lottie.host/67206804-06d6-4691-9a6d-86e63949ba9b/dummy.json', // Placeholder for speaking
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.volume_up, color: Colors.blueAccent, size: 60),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getHelperText(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.listening:
        return "Đang lắng nghe...";
      case AssistantStatus.processing:
        return "Đang xử lý...";
      case AssistantStatus.speaking:
        return "Đang trả lời...";
      case AssistantStatus.error:
        return "Có lỗi xảy ra";
      default:
        return "Nhấn và giữ để nói";
    }
  }
}

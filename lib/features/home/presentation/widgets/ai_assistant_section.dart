import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Section 6: AI Assistant — text/voice input with smart suggestions.
class AiAssistantSection extends StatefulWidget {
  final ValueChanged<String> onMessageSent;
  final VoidCallback onVoiceTap;
  final VoidCallback onOpenFullChat;

  const AiAssistantSection({
    super.key,
    required this.onMessageSent,
    required this.onVoiceTap,
    required this.onOpenFullChat,
  });

  @override
  State<AiAssistantSection> createState() => _AiAssistantSectionState();
}

class _AiAssistantSectionState extends State<AiAssistantSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  static const List<String> _suggestions = [
    'Tôi bị đau đầu liên tục',
    'Tìm bác sĩ tim mạch',
    'Lịch uống thuốc hôm nay',
    'Kết quả xét nghiệm gần nhất',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onMessageSent(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text('Trợ lý AI ICare', style: AppTextStyles.heading3),
              ),
              TextButton(
                onPressed: widget.onOpenFullChat,
                child: Text('Mở chat', style: AppTextStyles.link.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasFocus ? AppColors.primary : AppColors.divider,
                width: _hasFocus ? 1.5 : 1,
              ),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'Hỏi tôi về sức khỏe của bạn...',
                            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: AppTextStyles.body,
                          onSubmitted: (_) => _send(),
                          maxLines: 2,
                          minLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary),
                        onPressed: widget.onVoiceTap,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: _send,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                if (!_hasFocus) ...[
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions.map((s) => _SuggestionChip(
                        label: s,
                        onTap: () {
                          _controller.text = s;
                          _focusNode.requestFocus();
                        },
                      )).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

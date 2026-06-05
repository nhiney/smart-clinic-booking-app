import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/widgets/app_card.dart';

class AISuggestionCard extends StatelessWidget {
  final String code;
  final String title;
  final int confidence;
  final VoidCallback? onAdd;

  const AISuggestionCard({
    super.key,
    required this.code,
    required this.title,
    required this.confidence,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.subtitle),
                const SizedBox(height: 4),
                Text(
                  '$confidence%',
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onAdd != null)
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('+'),
            ),
        ],
      ),
    );
  }
}

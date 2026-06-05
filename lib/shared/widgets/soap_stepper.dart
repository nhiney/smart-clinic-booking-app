import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/widgets/app_card.dart';

class SoapStepper extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTap;

  const SoapStepper({
    super.key,
    required this.currentStep,
    this.onStepTap,
  });

  static const _items = [
    ('S', 'Subjective'),
    ('O', 'Objective'),
    ('A', 'Assessment'),
    ('P', 'Plan'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = index == currentStep;
          final isDone = index < currentStep;

          return Expanded(
            child: InkWell(
              onTap: onStepTap == null ? null : () => onStepTap!(index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(right: index == _items.length - 1 ? 0 : 10),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colors.primary
                      : isDone
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? context.colors.primary : context.colors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      item.$1,
                      style: context.textStyles.subtitle.copyWith(
                        color: isActive ? Colors.white : context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.caption.copyWith(
                        color: isActive ? Colors.white70 : context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

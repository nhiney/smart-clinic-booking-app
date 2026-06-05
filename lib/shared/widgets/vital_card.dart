import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/widgets/app_card.dart';

class VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isAlert;

  const VitalCard({
    super.key,
    required this.title,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? context.colors.error : context.colors.primary;
    final bgColor = isAlert ? context.colors.error.withValues(alpha: 0.06) : null;

    return AppCard(
      padding: const EdgeInsets.all(14),
      color: bgColor,
      border: Border.all(color: color.withValues(alpha: 0.22), width: isAlert ? 1.5 : 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.textStyles.caption.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isAlert)
                Icon(
                  Icons.warning_amber_rounded,
                  color: context.colors.error,
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/widgets/app_card.dart';
import '../../features/clinical/clinical/domain/entities/medication_plan_item.dart';

class MedicationCard extends StatelessWidget {
  final MedicationPlanItem medication;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.medication_liquid_outlined,
                  color: context.colors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name, style: context.textStyles.subtitle),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} • ${medication.timesPerDay} lần/ngày • ${medication.days} ngày',
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (medication.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        medication.notes,
                        style: context.textStyles.caption.copyWith(
                          color: context.colors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

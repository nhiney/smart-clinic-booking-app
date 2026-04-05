import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/medication_reminder.dart';

/// Section 4: Medication Reminder — today's medications with mark-as-taken action.
class MedicationReminderSection extends StatelessWidget {
  final List<MedicationReminder> reminders;
  final ValueChanged<String> onMarkTaken;

  const MedicationReminderSection({
    super.key,
    required this.reminders,
    required this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Text('Thuốc hôm nay', style: AppTextStyles.heading3)),
              const _PendingBadge(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _MedicationTile(
            reminder: reminders[index],
            onMarkTaken: () => onMarkTaken(reminders[index].id),
          ),
        ),
      ],
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Hôm nay',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final MedicationReminder reminder;
  final VoidCallback onMarkTaken;

  const _MedicationTile({required this.reminder, required this.onMarkTaken});

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: reminder.isTaken ? AppColors.success.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reminder.isTaken ? AppColors.success.withValues(alpha: 0.3) : AppColors.divider,
        ),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: reminder.isTaken
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: reminder.isTaken ? AppColors.success : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.medicationName,
                  style: AppTextStyles.subtitle.copyWith(
                    decoration: reminder.isTaken ? TextDecoration.lineThrough : null,
                    color: reminder.isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${reminder.dosage} • ${timeFormatter.format(reminder.scheduledTime)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (!reminder.isTaken)
            GestureDetector(
              onTap: onMarkTaken,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Đã uống',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Section 2: Quick Actions grid — 6 core feature shortcuts.
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback onViewAppointments;
  final VoidCallback onMedicalRecords;
  final VoidCallback onPrescriptions;
  final VoidCallback onContactSupport;
  final VoidCallback onVoiceAssistant;

  const QuickActionsGrid({
    super.key,
    required this.onBookAppointment,
    required this.onViewAppointments,
    required this.onMedicalRecords,
    required this.onPrescriptions,
    required this.onContactSupport,
    required this.onVoiceAssistant,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: 'Đặt khám',
        color: AppColors.primary,
        onTap: onBookAppointment,
      ),
      _QuickAction(
        icon: Icons.assignment_rounded,
        label: 'Lịch hẹn',
        color: const Color(0xFF7B61FF),
        onTap: onViewAppointments,
      ),
      _QuickAction(
        icon: Icons.folder_shared_rounded,
        label: 'Hồ sơ bệnh',
        color: const Color(0xFF00B8A9),
        onTap: onMedicalRecords,
      ),
      _QuickAction(
        icon: Icons.medication_rounded,
        label: 'Đơn thuốc',
        color: const Color(0xFFFF6B6B),
        onTap: onPrescriptions,
      ),
      _QuickAction(
        icon: Icons.support_agent_rounded,
        label: 'Hỗ trợ',
        color: const Color(0xFFFFA41B),
        onTap: onContactSupport,
      ),
      _QuickAction(
        icon: Icons.mic_rounded,
        label: 'Trợ lý AI',
        color: const Color(0xFF4ECDC4),
        onTap: onVoiceAssistant,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Dịch vụ nhanh', style: AppTextStyles.heading3),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: actions
                .map((a) => _QuickActionTile(action: a))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

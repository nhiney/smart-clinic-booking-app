import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String role; // 'patient', 'doctor', or 'all'

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.role = 'all',
  });
}

class QuickActionsGrid extends StatelessWidget {
  final String userRole;
  final VoidCallback onBookAppointment;
  final VoidCallback onViewAppointments;
  final VoidCallback onMedicalRecords;
  final VoidCallback onPrescriptions;
  final VoidCallback onContactSupport;
  final VoidCallback onVoiceAssistant;
  final VoidCallback onInpatientAdmission;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPricing;
  final VoidCallback onSurveys;
  final VoidCallback onProfile;

  const QuickActionsGrid({
    super.key,
    required this.userRole,
    required this.onBookAppointment,
    required this.onViewAppointments,
    required this.onMedicalRecords,
    required this.onPrescriptions,
    required this.onContactSupport,
    required this.onVoiceAssistant,
    required this.onInpatientAdmission,
    required this.onNotificationSettings,
    required this.onPricing,
    required this.onSurveys,
    required this.onProfile,
  });


  @override
  Widget build(BuildContext context) {
    final allActions = [
      QuickAction(
        label: 'Đặt khám',
        icon: Icons.add_task_rounded,
        color: AppColors.primary,
        onTap: onBookAppointment,
        role: 'patient',
      ),
      QuickAction(
        label: 'Lịch sử khám',
        icon: Icons.history_rounded,
        color: AppColors.success,
        onTap: onViewAppointments,
        role: 'patient',
      ),
      QuickAction(
        label: 'Thanh toán',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.primary,
        onTap: onPricing,
        role: 'patient',
      ),
      QuickAction(
        label: 'Khảo sát',
        icon: Icons.poll_rounded,
        color: AppColors.warning,
        onTap: onSurveys,
        role: 'patient',
      ),
      QuickAction(
        label: 'Đơn thuốc',
        icon: Icons.medication_rounded,
        color: AppColors.warning,
        onTap: onPrescriptions,
        role: 'patient',
      ),
      QuickAction(
        label: 'Nhập viện',
        icon: Icons.hotel_rounded,
        color: Colors.orange,
        onTap: onInpatientAdmission,
        role: 'patient',
      ),
      QuickAction(
        label: 'Cài đặt TB',
        icon: Icons.settings_suggest_rounded,
        color: AppColors.primary,
        onTap: onNotificationSettings,
      ),
      QuickAction(
        label: 'Bệnh nhân',
        icon: Icons.people_alt_rounded,
        color: AppColors.primaryDark,
        onTap: () {},
        role: 'doctor',
      ),
      QuickAction(
        label: 'Lịch trực',
        icon: Icons.event_note_rounded,
        color: const Color(0xFF009688), // Teal
        onTap: () {},
        role: 'doctor',
      ),
      QuickAction(
        label: 'Hồ sơ',
        icon: Icons.folder_shared_rounded,
        color: const Color(0xFF9C27B0), // Purple
        onTap: onMedicalRecords,
      ),
      QuickAction(
        label: 'Tiêm chủng',
        icon: Icons.vaccines_rounded,
        color: AppColors.error,
        onTap: () {},
        role: 'patient',
      ),
      QuickAction(
        label: 'Hỗ trợ',
        icon: Icons.headset_mic_rounded,
        color: AppColors.textSecondary,
        onTap: onContactSupport,
      ),
      QuickAction(
        label: 'AI Assistant',
        icon: Icons.smart_toy_rounded,
        color: AppColors.primary,
        onTap: onVoiceAssistant,
      ),
      QuickAction(
        label: 'Quản lý cá nhân',
        icon: Icons.manage_accounts_rounded,
        color: AppColors.secondary,
        onTap: onProfile,
        role: 'patient',
      ),
    ];


    final filteredActions = allActions.where((a) => a.role == 'all' || a.role == userRole).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chức năng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_rounded, size: 18, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredActions.length,
              itemBuilder: (context, index) {
                return _QuickActionTile(action: filteredActions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primarySurface, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: action.color.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(action.icon, color: action.color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            action.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

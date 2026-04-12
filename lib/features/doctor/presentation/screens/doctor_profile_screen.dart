import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/doctor_controller.dart';

/// Tab Cá nhân — thông tin bác sĩ và đăng xuất.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<DoctorController>();
    final doctor = controller.currentDoctor;
    final user = context.watch<AuthController>().currentUser;
    final userEmail = user?.email;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.nav_profile),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: doctor == null && controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await context.read<DoctorController>().fetchDoctorProfile(user.id);
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: (doctor?.imageUrl.isNotEmpty ?? false)
                          ? NetworkImage(doctor!.imageUrl)
                          : const NetworkImage('https://i.pravatar.cc/150?u=doctor'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doctor?.name ?? '—',
                    textAlign: TextAlign.center,
                    style: context.textStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${doctor?.specialty ?? "—"} · ${doctor?.displayClinic ?? doctor?.hospital ?? "—"}',
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
                  if (userEmail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _InfoRow(icon: Icons.phone_outlined, label: 'Điện thoại', value: doctor?.phone ?? '—'),
                  _InfoRow(icon: Icons.star_outline, label: 'Đánh giá', value: '${doctor?.rating.toStringAsFixed(1) ?? "—"} (${doctor?.totalReviews ?? 0})'),
                  _InfoRow(icon: Icons.work_outline, label: 'Kinh nghiệm', value: '${doctor?.experience ?? 0} năm'),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, l10n),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.logout_button),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout_confirm_title),
        content: Text(l10n.logout_confirm_message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel_button_text)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthController>().logout();
            },
            child: Text(l10n.logout_button, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint)),
                Text(value, style: context.textStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

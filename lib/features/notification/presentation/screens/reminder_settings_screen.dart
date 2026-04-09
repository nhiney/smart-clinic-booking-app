import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../controllers/notification_controller.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _remind1Day = true;
  bool _remind3Hours = true;
  bool _remind30Mins = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt nhắc nhở'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Reminders (\$0)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tùy chỉnh thời gian nhận thông báo cho lịch hẹn của bạn.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildSettingTile(
              title: "Trước 1 ngày",
              subtitle: "Thông báo qua Push FCM",
              value: _remind1Day,
              onChanged: (v) => setState(() => _remind1Day = v),
              icon: Icons.calendar_today_outlined,
            ),
            _buildSettingTile(
              title: "Trước 3 giờ",
              subtitle: "Thông báo qua Push FCM",
              value: _remind3Hours,
              onChanged: (v) => setState(() => _remind3Hours = v),
              icon: Icons.access_time,
            ),
            _buildSettingTile(
              title: "Trước 30 phút",
              subtitle: "Thông báo Local (Ưu tiên)",
              value: _remind30Mins,
              onChanged: (v) => setState(() => _remind30Mins = v),
              icon: Icons.notifications_active_outlined,
            ),
            const SizedBox(height: 32),
            _buildUrgencyCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildUrgencyCard() {
    return Consumer<NotificationController>(
      builder: (_, controller, __) {
        final multiplier = controller.userBehavior?.urgencyMultiplier ?? 1.0;
        final missedCount = controller.userBehavior?.missedAppointmentsCount ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_graph, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'AI Behavior Tracking',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Mức độ nhắc nhở (Smart Urgency)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Dựa trên lịch sử đi khám của bạn, chúng tôi điều chỉnh tần suất thông báo để đảm bảo bạn không lỡ lịch.',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Số lần lỡ', '$missedCount lần'),
                  _buildStatItem('Hệ số ưu tiên', 'x${multiplier.toStringAsFixed(1)}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

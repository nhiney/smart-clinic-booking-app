import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
    this.onTap,
    this.onCancel,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.statusPending;
      case 'confirmed':
        return AppColors.statusConfirmed;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textHint;
    }
  }

  String _statusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info + status
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName, style: AppTextStyles.subtitle),
                      const SizedBox(height: 2),
                      Text(specialty, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(dateTime),
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:mm').format(dateTime),
                  style: AppTextStyles.bodySmall,
                ),
                const Spacer(),
                if (status.toLowerCase() == 'pending' && onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

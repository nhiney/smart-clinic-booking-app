import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../notification/domain/entities/notification_entity.dart';

/// Section 9: Notifications Preview — latest 3 notifications with View All.
class NotificationsPreview extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final VoidCallback onViewAll;

  const NotificationsPreview({
    super.key,
    required this.notifications,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    final preview = notifications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Text('Thông báo', style: AppTextStyles.heading3)),
              TextButton(
                onPressed: onViewAll,
                child: Text('Xem tất cả', style: AppTextStyles.link.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
            ),
            child: Column(
              children: [
                for (int i = 0; i < preview.length; i++) ...[
                  _NotificationTile(notification: preview[i]),
                  if (i < preview.length - 1)
                    const Divider(height: 1, indent: 58, color: AppColors.divider),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final color = _typeColor(notification.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon(notification.type), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            timeFormatter.format(notification.createdAt),
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'appointment': return AppColors.primary;
      case 'medication': return AppColors.warning;
      case 'result': return AppColors.success;
      case 'system': return AppColors.textSecondary;
      default: return AppColors.info;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'appointment': return Icons.calendar_today_rounded;
      case 'medication': return Icons.medication_rounded;
      case 'result': return Icons.science_rounded;
      default: return Icons.notifications_rounded;
    }
  }
}

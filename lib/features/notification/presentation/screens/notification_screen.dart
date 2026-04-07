import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../controllers/notification_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<NotificationController>().loadNotifications(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: "Trung tâm Thông báo",
        actions: [
          Consumer<NotificationController>(
            builder: (_, controller, __) {
              if (controller.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    final auth = context.read<AuthController>();
                    if (auth.currentUser != null) {
                      controller.markAllAsRead(auth.currentUser!.id);
                    }
                  },
                  child: const Text(
                    "Đọc tất cả",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: "Thông báo Push"),
            Tab(text: "Lịch sử SMS/Email"),
          ],
        ),
      ),
      body: Consumer<NotificationController>(
        builder: (_, controller, __) {
          if (controller.isLoading) {
            return const LoadingWidget(itemCount: 4);
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPushNotificationsTab(controller),
              _buildCommunicationLogsTab(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPushNotificationsTab(NotificationController controller) {
    if (controller.notifications.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_off_outlined,
        title: "Chưa có thông báo",
        subtitle: "Bạn sẽ nhận thông báo khi có lịch hẹn hoặc nhắc thuốc",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.notifications.length,
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        return _buildNotificationCard(notification, controller);
      },
    );
  }

  Widget _buildCommunicationLogsTab(NotificationController controller) {
    if (controller.notificationLogs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_edu_outlined,
        title: "Chưa có liên lạc",
        subtitle: "Các tin nhắn SMS và Email giả lập sẽ được lưu tại đây (\$0 phí)",
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.notificationLogs.length,
      itemBuilder: (context, index) {
        final log = controller.notificationLogs[index];
        return _buildCommunicationLogCard(log);
      },
    );
  }

  Widget _buildCommunicationLogCard(NotificationLogEntity log) {
    final isEmail = log.type == 'email';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isEmail ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            child: Icon(
              isEmail ? Icons.email_outlined : Icons.sms_outlined,
              color: isEmail ? Colors.blue : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEmail ? "Email Đã Log" : "SMS Đã Log",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      DateFormat('HH:mm, dd/MM').format(log.createdAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Đến: ${log.recipient}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  log.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification, NotificationController controller) {
    // Legacy mapping or expansion
    IconData icon = Icons.notifications;
    Color color = AppColors.primary;
    
    if (notification.type == 'appointment') {
      icon = Icons.calendar_today;
      color = AppColors.primary;
    } else if (notification.type == 'medication') {
      icon = Icons.medication;
      color = AppColors.success;
    } else if (notification.type == 'admission') {
      icon = Icons.hotel_outlined;
      color = Colors.orange;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.cardBackground
                : color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6),
            ],
            border: notification.isRead
                ? null
                : Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}

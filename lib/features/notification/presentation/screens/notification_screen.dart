import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../controllers/notification_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// ─── Filter enum ─────────────────────────────────────────────────────────────

enum _Filter { all, unread, appointment, medication, admission, comms }

extension _FilterLabel on _Filter {
  String get label {
    switch (this) {
      case _Filter.all: return 'Tất cả';
      case _Filter.unread: return 'Chưa đọc';
      case _Filter.appointment: return 'Lịch hẹn';
      case _Filter.medication: return 'Thuốc';
      case _Filter.admission: return 'Nhập viện';
      case _Filter.comms: return 'SMS / Email';
    }
  }

  IconData get icon {
    switch (this) {
      case _Filter.all: return Icons.apps_rounded;
      case _Filter.unread: return Icons.mark_email_unread_outlined;
      case _Filter.appointment: return Icons.calendar_today_outlined;
      case _Filter.medication: return Icons.medication_outlined;
      case _Filter.admission: return Icons.hotel_outlined;
      case _Filter.comms: return Icons.forum_outlined;
    }
  }
}

// ─── Type metadata helper ─────────────────────────────────────────────────────

_NotifMeta _metaFor(String type) {
  if (type.startsWith('appointment')) {
    return _NotifMeta(
      icon: Icons.calendar_today_rounded,
      color: AppColors.primary,
      label: 'Lịch hẹn',
    );
  }
  if (type == 'medication') {
    return _NotifMeta(
      icon: Icons.medication_rounded,
      color: const Color(0xFF22C55E),
      label: 'Thuốc',
    );
  }
  if (type == 'admission') {
    return _NotifMeta(
      icon: Icons.hotel_rounded,
      color: const Color(0xFFF97316),
      label: 'Nhập viện',
    );
  }
  return _NotifMeta(
    icon: Icons.notifications_rounded,
    color: const Color(0xFF8B5CF6),
    label: 'Hệ thống',
  );
}

class _NotifMeta {
  final IconData icon;
  final Color color;
  final String label;
  const _NotifMeta({required this.icon, required this.color, required this.label});
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  _Filter _activeFilter = _Filter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<NotificationController>().loadNotifications(auth.currentUser!.id);
      }
    });
  }

  List<NotificationEntity> _filtered(List<NotificationEntity> all) {
    switch (_activeFilter) {
      case _Filter.all: return all;
      case _Filter.unread: return all.where((n) => !n.isRead).toList();
      case _Filter.appointment:
        return all.where((n) => n.type.startsWith('appointment')).toList();
      case _Filter.medication:
        return all.where((n) => n.type == 'medication').toList();
      case _Filter.admission:
        return all.where((n) => n.type == 'admission').toList();
      case _Filter.comms: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (_, controller, __) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              _SliverHeader(
                controller: controller,
                onMarkAll: () {
                  final auth = context.read<AuthController>();
                  if (auth.currentUser != null) {
                    controller.markAllAsRead(auth.currentUser!.id);
                  }
                },
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarDelegate(
                  activeFilter: _activeFilter,
                  onSelect: (f) => setState(() => _activeFilter = f),
                ),
              ),
              if (controller.isLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(itemCount: 5),
                )
              else if (_activeFilter == _Filter.comms)
                _CommsSliver(logs: controller.notificationLogs)
              else
                _NotificationsSliver(
                  items: _filtered(controller.notifications),
                  controller: controller,
                  filter: _activeFilter,
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sliver app bar / hero header ─────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  final NotificationController controller;
  final VoidCallback onMarkAll;

  const _SliverHeader({required this.controller, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    final unread = controller.unreadCount;
    return SliverAppBar(
      expandedHeight: 120,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: [
        if (unread > 0)
          TextButton.icon(
            onPressed: onMarkAll,
            icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Đọc tất cả',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        background: _HeaderBackground(unread: unread, total: controller.notifications.length),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final int unread;
  final int total;

  const _HeaderBackground({required this.unread, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          // stats row at bottom
          Positioned(
            left: 56,
            bottom: 44,
            child: Row(
              children: [
                _Stat(value: total, label: 'Tổng'),
                const SizedBox(width: 20),
                _Stat(value: unread, label: 'Chưa đọc', highlight: unread > 0),
                const SizedBox(width: 20),
                _Stat(value: total - unread, label: 'Đã đọc'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final bool highlight;

  const _Stat({required this.value, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: highlight ? const Color(0xFFFFD60A) : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final _Filter activeFilter;
  final ValueChanged<_Filter> onSelect;

  const _FilterBarDelegate({required this.activeFilter, required this.onSelect});

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.activeFilter != activeFilter;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 52,
      color: const Color(0xFFF5F7FA),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: _Filter.values.map((f) {
          final active = f == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                      : [const BoxShadow(color: Color(0x0D000000), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f.icon, size: 14, color: active ? Colors.white : Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      f.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Notifications sliver ─────────────────────────────────────────────────────

class _NotificationsSliver extends StatelessWidget {
  final List<NotificationEntity> items;
  final NotificationController controller;
  final _Filter filter;

  const _NotificationsSliver({
    required this.items,
    required this.controller,
    required this.filter,
  });

  Map<String, List<NotificationEntity>> _groupByDate(List<NotificationEntity> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<NotificationEntity>>{};
    for (final n in list) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final String key;
      if (!d.isBefore(today)) {
        key = 'Hôm nay';
      } else if (!d.isBefore(yesterday)) {
        key = 'Hôm qua';
      } else if (!d.isBefore(weekAgo)) {
        key = 'Tuần này';
      } else {
        key = DateFormat('MMMM yyyy', 'vi').format(n.createdAt);
      }
      groups.putIfAbsent(key, () => []).add(n);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: filter == _Filter.unread
              ? Icons.mark_email_read_outlined
              : Icons.notifications_off_outlined,
          title: filter == _Filter.unread
              ? 'Bạn đã đọc hết thông báo!'
              : 'Chưa có thông báo nào',
          subtitle: 'Thông báo mới sẽ xuất hiện tại đây',
        ),
      );
    }

    final groups = _groupByDate(items);
    final sliverItems = <Widget>[];
    for (final entry in groups.entries) {
      sliverItems.add(_DateHeader(label: entry.key));
      for (final n in entry.value) {
        sliverItems.add(_NotifCard(notification: n, controller: controller));
      }
    }
    sliverItems.add(const SizedBox(height: 24));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate(sliverItems),
      ),
    );
  }
}

// ─── Date section header ──────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        ],
      ),
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotificationEntity notification;
  final NotificationController controller;

  const _NotifCard({required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(notification.type);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      background: _SwipeAction(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF3B82F6),
        icon: Icons.done_all_rounded,
        label: 'Đã đọc',
      ),
      secondaryBackground: _SwipeAction(
        alignment: Alignment.centerRight,
        color: const Color(0xFFEF4444),
        icon: Icons.delete_outline_rounded,
        label: 'Xoá',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!isRead) controller.markAsRead(notification.id);
          return false;
        }
        return true;
      },
      onDismissed: (_) => controller.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!isRead) controller.markAsRead(notification.id);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isRead ? Colors.black.withValues(alpha: 0.04) : meta.color.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    color: isRead ? Colors.grey.shade200 : meta.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon badge
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: meta.color.withValues(alpha: isRead ? 0.08 : 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(meta.icon, color: isRead ? meta.color.withValues(alpha: 0.5) : meta.color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Type chip
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: meta.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        meta.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: meta.color,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: meta.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                    color: isRead ? const Color(0xFF6B7280) : const Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notification.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatTime(notification.createdAt),
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('HH:mm, dd/MM/yyyy').format(dt);
  }
}

// ─── Swipe action background ──────────────────────────────────────────────────

class _SwipeAction extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeAction({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Communications sliver ────────────────────────────────────────────────────

class _CommsSliver extends StatelessWidget {
  final List<NotificationLogEntity> logs;
  const _CommsSliver({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.forum_outlined,
          title: 'Chưa có liên lạc',
          subtitle: 'Lịch sử SMS và Email sẽ được lưu tại đây',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _CommsCard(log: logs[i]),
          childCount: logs.length,
        ),
      ),
    );
  }
}

class _CommsCard extends StatelessWidget {
  final NotificationLogEntity log;
  const _CommsCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final isEmail = log.type == 'email';
    final color = isEmail ? const Color(0xFF3B82F6) : const Color(0xFF22C55E);
    final icon = isEmail ? Icons.email_rounded : Icons.sms_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isEmail ? 'EMAIL' : 'SMS',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('HH:mm, dd/MM').format(log.createdAt),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Gửi đến: ${log.recipient}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              log.content,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

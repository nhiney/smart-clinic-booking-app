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

// ─── Type metadata ─────────────────────────────────────────────────────────────

class _Meta {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  const _Meta({required this.icon, required this.color, required this.bg, required this.label});
}

_Meta _metaFor(String type) {
  if (type.startsWith('appointment')) {
    return const _Meta(
      icon: Icons.event_note_rounded,
      color: Color(0xFF1D5BDC),
      bg: Color(0xFFDEEBFF),
      label: 'Lịch hẹn',
    );
  }
  if (type == 'medication') {
    return const _Meta(
      icon: Icons.medication_liquid_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFD1FAE5),
      label: 'Thuốc',
    );
  }
  if (type == 'admission') {
    return const _Meta(
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFD97706),
      bg: Color(0xFFFEF3C7),
      label: 'Nhập viện',
    );
  }
  return const _Meta(
    icon: Icons.campaign_rounded,
    color: Color(0xFF7C3AED),
    bg: Color(0xFFEDE9FE),
    label: 'Hệ thống',
  );
}

// ─── Filter enum ──────────────────────────────────────────────────────────────

enum _Filter { all, unread, appointment, medication, admission, comms }

extension _FilterX on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:         return 'Tất cả';
      case _Filter.unread:      return 'Chưa đọc';
      case _Filter.appointment: return 'Lịch hẹn';
      case _Filter.medication:  return 'Thuốc';
      case _Filter.admission:   return 'Nhập viện';
      case _Filter.comms:       return 'SMS / Email';
    }
  }

  IconData get icon {
    switch (this) {
      case _Filter.all:         return Icons.grid_view_rounded;
      case _Filter.unread:      return Icons.fiber_new_rounded;
      case _Filter.appointment: return Icons.event_note_rounded;
      case _Filter.medication:  return Icons.medication_liquid_rounded;
      case _Filter.admission:   return Icons.local_hospital_rounded;
      case _Filter.comms:       return Icons.chat_bubble_outline_rounded;
    }
  }

  Color get activeColor {
    switch (this) {
      case _Filter.all:         return const Color(0xFF1D5BDC);
      case _Filter.unread:      return const Color(0xFFDC2626);
      case _Filter.appointment: return const Color(0xFF1D5BDC);
      case _Filter.medication:  return const Color(0xFF059669);
      case _Filter.admission:   return const Color(0xFFD97706);
      case _Filter.comms:       return const Color(0xFF7C3AED);
    }
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  final VoidCallback? onGoHome;
  const NotificationScreen({super.key, this.onGoHome});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  _Filter _filter = _Filter.all;

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

  List<NotificationEntity> _applyFilter(List<NotificationEntity> all) {
    switch (_filter) {
      case _Filter.all:         return all;
      case _Filter.unread:      return all.where((n) => !n.isRead).toList();
      case _Filter.appointment: return all.where((n) => n.type.startsWith('appointment')).toList();
      case _Filter.medication:  return all.where((n) => n.type == 'medication').toList();
      case _Filter.admission:   return all.where((n) => n.type == 'admission').toList();
      case _Filter.comms:       return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (_, ctrl, __) => Container(
        color: AppColors.background,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(ctrl, widget.onGoHome),
            _buildFilterBar(),
            if (ctrl.isLoading)
              const SliverFillRemaining(child: LoadingWidget(itemCount: 5))
            else if (_filter == _Filter.comms)
              _CommsSliver(logs: ctrl.notificationLogs)
            else
              _NotifSliver(
                items: _applyFilter(ctrl.notifications),
                ctrl: ctrl,
                filter: _filter,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationController ctrl, VoidCallback? onGoHome) {
    final unread = ctrl.unreadCount;

    return SliverToBoxAdapter(
      child: Container(
        height: kToolbarHeight,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // Back button — same style as BrandedAppBar
            if (onGoHome != null)
              InkWell(
                onTap: onGoHome,
                borderRadius: BorderRadius.circular(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Quay lại',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Title
            Text(
              'Thông báo',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            // Mark-all action
            if (unread > 0)
              TextButton(
                onPressed: () {
                  final uid = context.read<AuthController>().currentUser?.id;
                  if (uid != null) ctrl.markAllAsRead(uid);
                },
                child: Text(
                  'Đọc tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterDelegate(active: _filter, onSelect: (f) => setState(() => _filter = f)),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final _Filter active;
  final ValueChanged<_Filter> onSelect;

  const _FilterDelegate({required this.active, required this.onSelect});

  @override double get minExtent => 58;
  @override double get maxExtent => 58;
  @override bool shouldRebuild(_FilterDelegate old) => old.active != active;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: overlapsContent
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _Filter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f    = _Filter.values[i];
          final isOn = f == active;
          final col  = f.activeColor;

          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isOn ? col : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isOn ? col : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: isOn
                    ? [BoxShadow(color: col.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.icon, size: 13, color: isOn ? Colors.white : const Color(0xFF9CA3AF)),
                  const SizedBox(width: 5),
                  Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                      color: isOn ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Date section label ───────────────────────────────────────────────────────

class _DateLabel extends StatelessWidget {
  final String label;
  const _DateLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D4ED8),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: const Color(0xFFE5E7EB), height: 1)),
        ],
      ),
    );
  }
}

// ─── Notifications sliver ─────────────────────────────────────────────────────

class _NotifSliver extends StatelessWidget {
  final List<NotificationEntity> items;
  final NotificationController ctrl;
  final _Filter filter;

  const _NotifSliver({required this.items, required this.ctrl, required this.filter});

  static const _knownOrder = ['Hôm nay', 'Hôm qua', 'Tuần này'];

  Map<String, List<NotificationEntity>> _group(List<NotificationEntity> list) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));
    final week  = today.subtract(const Duration(days: 7));

    final out = <String, List<NotificationEntity>>{};
    for (final n in list) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final String k;
      if (!d.isBefore(today))     k = 'Hôm nay';
      else if (!d.isBefore(yest)) k = 'Hôm qua';
      else if (!d.isBefore(week)) k = 'Tuần này';
      else                        k = DateFormat('MMMM yyyy', 'vi').format(n.createdAt);
      out.putIfAbsent(k, () => []).add(n);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: filter == _Filter.unread
              ? Icons.mark_email_read_outlined
              : Icons.notifications_off_outlined,
          title: filter == _Filter.unread ? 'Bạn đã đọc hết!' : 'Chưa có thông báo nào',
          subtitle: 'Thông báo mới sẽ xuất hiện tại đây',
        ),
      );
    }

    final groups = _group(items);
    final keys = [
      ..._knownOrder.where(groups.containsKey),
      ...groups.keys.where((k) => !_knownOrder.contains(k)),
    ];

    final children = <Widget>[];
    for (final key in keys) {
      children.add(_DateLabel(label: key));
      for (final n in groups[key]!) {
        children.add(_NotifCard(notification: n, ctrl: ctrl));
      }
    }
    children.add(const SizedBox(height: 100));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }
}

// ─── Notification card ────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotificationEntity notification;
  final NotificationController ctrl;

  const _NotifCard({required this.notification, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final meta   = _metaFor(notification.type);
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      background: _SwipeBg(
        alignment: Alignment.centerLeft,
        color: const Color(0xFF2563EB),
        icon: Icons.done_all_rounded,
        label: 'Đã đọc',
      ),
      secondaryBackground: _SwipeBg(
        alignment: Alignment.centerRight,
        color: const Color(0xFFEF4444),
        icon: Icons.delete_sweep_rounded,
        label: 'Xoá',
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          if (!isRead) ctrl.markAsRead(notification.id);
          return false;
        }
        return true;
      },
      onDismissed: (_) => ctrl.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () { if (!isRead) ctrl.markAsRead(notification.id); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isRead
                    ? Colors.black.withValues(alpha: 0.05)
                    : meta.color.withValues(alpha: 0.12),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // unread left bar
                if (!isRead)
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [meta.color, meta.color.withValues(alpha: 0.5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(isRead ? 16 : 20, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(meta.icon, color: meta.color, size: 22),
                      ),
                      const SizedBox(width: 13),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: meta.bg,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    meta.label,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: meta.color,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _fmt(notification.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFB0BAC7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!isRead) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: meta.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: meta.color.withValues(alpha: 0.5), blurRadius: 4)],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                color: isRead ? const Color(0xFF6B7280) : const Color(0xFF111827),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: isRead ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                height: 1.45,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours   < 24) return '${diff.inHours} giờ';
    if (diff.inDays    <  7) return '${diff.inDays} ngày';
    return DateFormat('dd/MM').format(dt);
  }
}

// ─── Swipe background ─────────────────────────────────────────────────────────

class _SwipeBg extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _SwipeBg({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
          ),
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
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chưa có liên lạc',
          subtitle: 'Lịch sử SMS và Email sẽ được lưu tại đây',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
    final color   = isEmail ? const Color(0xFF2563EB) : const Color(0xFF059669);
    final bg      = isEmail ? const Color(0xFFDBEAFE) : const Color(0xFFD1FAE5);
    final icon    = isEmail ? Icons.email_rounded     : Icons.sms_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
                          child: Text(
                            isEmail ? 'EMAIL' : 'SMS',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm · dd/MM').format(log.createdAt),
                          style: const TextStyle(fontSize: 11, color: Color(0xFFB0BAC7), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gửi đến: ${log.recipient}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.content,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.45),
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
    );
  }
}

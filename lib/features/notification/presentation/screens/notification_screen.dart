import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../controllers/notification_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────

const _kHeaderTop = Color(0xFF38BDF8);    // sky-400
const _kHeaderBot = Color(0xFF0EA5E9);    // sky-500
const _kBg        = Color(0xFFF0F7FF);    // very light blue tint

// ─── Filter enum ─────────────────────────────────────────────────────────────

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
      case _Filter.all:         return Icons.apps_rounded;
      case _Filter.unread:      return Icons.mark_email_unread_outlined;
      case _Filter.appointment: return Icons.calendar_today_outlined;
      case _Filter.medication:  return Icons.medication_outlined;
      case _Filter.admission:   return Icons.hotel_outlined;
      case _Filter.comms:       return Icons.forum_outlined;
    }
  }
}

// ─── Type metadata ────────────────────────────────────────────────────────────

class _Meta {
  final IconData icon;
  final Color color;
  final String label;
  const _Meta({required this.icon, required this.color, required this.label});
}

_Meta _metaFor(String type) {
  if (type.startsWith('appointment')) {
    return const _Meta(icon: Icons.calendar_today_rounded, color: Color(0xFF2563EB), label: 'Lịch hẹn');
  }
  if (type == 'medication') {
    return const _Meta(icon: Icons.medication_rounded, color: Color(0xFF16A34A), label: 'Thuốc');
  }
  if (type == 'admission') {
    return const _Meta(icon: Icons.hotel_rounded, color: Color(0xFFEA580C), label: 'Nhập viện');
  }
  return const _Meta(icon: Icons.notifications_rounded, color: Color(0xFF7C3AED), label: 'Hệ thống');
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

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
    // NotificationScreen is used as a tab — no inner Scaffold needed.
    return Consumer<NotificationController>(
      builder: (_, ctrl, __) => ColoredBox(
        color: _kBg,
        child: CustomScrollView(
          slivers: [
            _Header(
              ctrl: ctrl,
              onMarkAll: () {
                final uid = context.read<AuthController>().currentUser?.id;
                if (uid != null) ctrl.markAllAsRead(uid);
              },
            ),
            _FilterBar(
              active: _filter,
              onSelect: (f) => setState(() => _filter = f),
            ),
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
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final NotificationController ctrl;
  final VoidCallback onMarkAll;

  const _Header({required this.ctrl, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    final unread = ctrl.unreadCount;
    final total  = ctrl.notifications.length;
    final read   = total - unread;

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kHeaderTop, _kHeaderBot],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Stack(
          children: [
            // decorative circle top-right
            Positioned(
              right: -30, top: -30,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 60, bottom: 0,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông báo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$unread mới',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (unread > 0)
                        GestureDetector(
                          onTap: onMarkAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.done_all_rounded, color: Colors.white, size: 15),
                                SizedBox(width: 4),
                                Text(
                                  'Đọc tất cả',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row — equal-width tiles
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _StatTile(value: total,  label: 'Tổng',     icon: Icons.inbox_rounded,          color: Colors.white),
                        _StatDivider(),
                        _StatTile(value: unread, label: 'Chưa đọc', icon: Icons.mark_email_unread_rounded, color: unread > 0 ? const Color(0xFFFFD60A) : Colors.white),
                        _StatDivider(),
                        _StatTile(value: read,   label: 'Đã đọc',   icon: Icons.mark_email_read_rounded,  color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.85), size: 18),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final _Filter active;
  final ValueChanged<_Filter> onSelect;

  const _FilterBar({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterDelegate(active: active, onSelect: onSelect),
    );
  }
}

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final _Filter active;
  final ValueChanged<_Filter> onSelect;

  const _FilterDelegate({required this.active, required this.onSelect});

  @override double get minExtent => 52;
  @override double get maxExtent => 52;

  @override
  bool shouldRebuild(_FilterDelegate old) => old.active != active;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 52,
      color: _kBg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _Filter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _Filter.values[i];
          final isActive = f == active;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _kHeaderBot : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? _kHeaderBot.withValues(alpha: 0.40)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: isActive ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.icon, size: 13, color: isActive ? Colors.white : Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? Colors.white : Colors.grey[700],
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

// ─── Notifications sliver ─────────────────────────────────────────────────────

class _NotifSliver extends StatelessWidget {
  final List<NotificationEntity> items;
  final NotificationController ctrl;
  final _Filter filter;

  const _NotifSliver({required this.items, required this.ctrl, required this.filter});

  static const _order = ['Hôm nay', 'Hôm qua', 'Tuần này'];

  Map<String, List<NotificationEntity>> _group(List<NotificationEntity> list) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));
    final week  = today.subtract(const Duration(days: 7));

    final groups = <String, List<NotificationEntity>>{};
    for (final n in list) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final String key;
      if (!d.isBefore(today)) {
        key = 'Hôm nay';
      } else if (!d.isBefore(yest)) {
        key = 'Hôm qua';
      } else if (!d.isBefore(week)) {
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

    final groups = _group(items);
    // Sort: known order first, then the rest
    final keys = [
      ..._order.where(groups.containsKey),
      ...groups.keys.where((k) => !_order.contains(k)),
    ];

    final children = <Widget>[];
    for (final key in keys) {
      children.add(_DateLabel(label: key));
      for (final n in groups[key]!) {
        children.add(_NotifCard(notification: n, ctrl: ctrl));
      }
    }
    children.add(const SizedBox(height: 100)); // bottom nav clearance

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }
}

// ─── Date label ───────────────────────────────────────────────────────────────

class _DateLabel extends StatelessWidget {
  final String label;
  const _DateLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.blueGrey.shade100, height: 1)),
        ],
      ),
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
        color: const Color(0xFF0EA5E9),
        icon: Icons.done_all_rounded,
        label: 'Đã đọc',
      ),
      secondaryBackground: _SwipeBg(
        alignment: Alignment.centerRight,
        color: const Color(0xFFEF4444),
        icon: Icons.delete_outline_rounded,
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: isRead
                ? Border.all(color: Colors.blueGrey.shade50)
                : Border.all(color: meta.color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: isRead
                    ? Colors.black.withValues(alpha: 0.04)
                    : meta.color.withValues(alpha: 0.10),
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
                  // left accent bar
                  Container(
                    width: 4,
                    color: isRead ? Colors.blueGrey.shade100 : meta.color,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: meta.color.withValues(alpha: isRead ? 0.07 : 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              meta.icon,
                              color: meta.color.withValues(alpha: isRead ? 0.55 : 1.0),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 11),
                          // text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _TypeChip(label: meta.label, color: meta.color, faded: isRead),
                                    const Spacer(),
                                    if (!isRead)
                                      Container(
                                        width: 8, height: 8,
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
                                    color: isRead ? const Color(0xFF6B7280) : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notification.body,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 11, color: Colors.blueGrey.shade300),
                                    const SizedBox(width: 3),
                                    Text(
                                      _fmt(notification.createdAt),
                                      style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade300),
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

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours   < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays    <  7) return '${diff.inDays} ngày trước';
    return DateFormat('HH:mm, dd/MM/yyyy').format(dt);
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool faded;
  const _TypeChip({required this.label, required this.color, required this.faded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: faded ? 0.07 : 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: faded ? 0.55 : 1.0),
          letterSpacing: 0.2,
        ),
      ),
    );
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
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 3),
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
    final color   = isEmail ? const Color(0xFF2563EB) : const Color(0xFF16A34A);
    final icon    = isEmail ? Icons.email_rounded     : Icons.sms_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade50),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
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
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _TypeChip(label: isEmail ? 'EMAIL' : 'SMS', color: color, faded: false),
                                const Spacer(),
                                Text(
                                  DateFormat('HH:mm · dd/MM').format(log.createdAt),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Đến: ${log.recipient}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/audit_log_entity.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _filter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAuditLogs();
    });
  }

  Color _color(AuditLogEntity log) {
    if (log.isLogin) return _C.green;
    if (log.isLogout) return _C.amber;
    return _C.primary;
  }

  IconData _icon(AuditLogEntity log) {
    if (log.isLogin) return Icons.login_rounded;
    if (log.isLogout) return Icons.logout_rounded;
    switch (log.action.toUpperCase()) {
      case 'CREATE':
        return Icons.add_circle_outline_rounded;
      case 'UPDATE':
        return Icons.edit_outlined;
      case 'DELETE':
        return Icons.delete_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final now = DateTime.now();

    final all = controller.auditLogs;
    final filtered = all.where((l) {
      switch (_filter) {
        case 'Đăng nhập':
          return l.isLogin;
        case 'Đăng xuất':
          return l.isLogout;
        default:
          return true;
      }
    }).toList();

    // gom nhóm theo ngày
    final groups = <String, List<AuditLogEntity>>{};
    for (final l in filtered) {
      groups.putIfAbsent(l.dayKey, () => []).add(l);
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text('Nhật ký truy cập',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AdminController>().fetchAuditLogs(),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : all.isEmpty
              ? _empty()
              : Column(
                  children: [
                    _summaryBar(all),
                    _filterChips(all),
                    Expanded(
                      child: filtered.isEmpty
                          ? _empty(filtered: true)
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              children: [
                                for (final entry in groups.entries) ...[
                                  _dayHeader(entry.key, now),
                                  ...entry.value.map((l) => _row(l, now)),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _summaryBar(List<AuditLogEntity> all) {
    final logins = all.where((l) => l.isLogin).length;
    final logouts = all.where((l) => l.isLogout).length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: [
          _stat('${all.length}', 'Sự kiện', _C.primary),
          const SizedBox(width: 12),
          _stat('$logins', 'Đăng nhập', _C.green),
          const SizedBox(width: 12),
          _stat('$logouts', 'Đăng xuất', _C.amber),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _filterChips(List<AuditLogEntity> all) {
    const filters = ['Tất cả', 'Đăng nhập', 'Đăng xuất'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 16),
          ...filters.map((f) {
            final sel = f == _filter;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? _C.primary : _C.bg,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: sel ? _C.primary : _C.border, width: 1.5),
                  ),
                  child: Text(f,
                      style: TextStyle(
                          color: sel ? Colors.white : _C.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _dayHeader(String dayKey, DateTime now) {
    final today =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final label = dayKey == today ? 'HÔM NAY' : dayKey;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _C.textSecondary,
              letterSpacing: 0.5)),
    );
  }

  Widget _row(AuditLogEntity log, DateTime now) {
    final color = _color(log);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(log), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(log.actionLabel,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(log.action.toUpperCase(),
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(log.displayDetail,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _C.textSecondary,
                        height: 1.35)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 13, color: _C.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(log.actorLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _C.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: _C.textSecondary),
                    const SizedBox(width: 4),
                    Text(log.timeLabel,
                        style: const TextStyle(
                            fontSize: 12, color: _C.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(log.relativeLabel(now),
              style: const TextStyle(
                  fontSize: 11,
                  color: _C.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _empty({bool filtered = false}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_toggle_off_rounded,
              size: 56, color: _C.textSecondary),
          const SizedBox(height: 12),
          Text(filtered ? 'Không có sự kiện phù hợp' : 'Chưa có nhật ký nào',
              style: const TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

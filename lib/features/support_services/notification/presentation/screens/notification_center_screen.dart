import 'package:flutter/material.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
}

class _Noti {
  final String category; // Lịch hẹn | Thuốc | Thanh toán | Đánh giá
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final String group; // Hôm nay | Hôm qua
  bool read;

  _Noti(this.category, this.icon, this.color, this.title, this.body, this.time,
      this.group,
      {this.read = false});
}

/// Trung tâm thông báo — lọc theo loại, đánh dấu đã đọc.
/// Route /notifications-center.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _filter = 'Tất cả';

  final List<_Noti> _items = [
    _Noti('Lịch hẹn', Icons.calendar_today_rounded, _C.primary, 'Nhắc lịch khám',
        'Lịch khám với BS. Trần Minh Quân lúc 09:30 ngày kia. Vui lòng đến trước 15 phút.',
        '14:38 · Vừa xong', 'Hôm nay'),
    _Noti('Thuốc', Icons.medication_rounded, _C.green, 'Đến giờ uống thuốc',
        'Amlodipine 5mg — 1 viên sáng. Đã uống 2/3 liều hôm nay.', '08:00',
        'Hôm nay'),
    _Noti('Thanh toán', Icons.receipt_long_rounded, _C.textSecondary,
        'Thanh toán thành công',
        'Hóa đơn HD-23052026-0451 đã được thanh toán: 350.000đ qua VNPay.', '16:24',
        'Hôm qua',
        read: true),
    _Noti('Đánh giá', Icons.star_rounded, _C.amber, 'Hãy đánh giá BS. Lan',
        'Bạn vừa khám xong với BS. Nguyễn Thị Lan. Đánh giá để giúp các bệnh nhân khác.',
        'Hôm qua', 'Hôm qua',
        read: true),
    _Noti('Lịch hẹn', Icons.event_available_rounded, _C.primary,
        'Xác nhận lịch hẹn',
        'Lịch khám Da liễu ngày 28/05 đã được xác nhận.', 'Hôm qua', 'Hôm qua',
        read: true),
  ];

  List<String> get _filters =>
      ['Tất cả', 'Lịch hẹn', 'Thuốc', 'Thanh toán', 'Đánh giá'];

  List<_Noti> get _filtered =>
      _filter == 'Tất cả' ? _items : _items.where((n) => n.category == _filter).toList();

  int get _unread => _items.where((n) => !n.read).length;

  int _countOf(String f) =>
      f == 'Tất cả' ? _items.length : _items.where((n) => n.category == f).length;

  void _markAllRead() => setState(() {
        for (final n in _items) {
          n.read = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final groups = <String, List<_Noti>>{};
    for (final n in filtered) {
      groups.putIfAbsent(n.group, () => []).add(n);
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thông báo',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
            Text('$_unread mới · Tổng ${_items.length} thông báo',
                style: const TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _unread == 0 ? null : _markAllRead,
            child: Text('Đánh dấu đã đọc',
                style: TextStyle(
                    color: _unread == 0 ? _C.textSecondary : _C.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filters.map((f) {
                final sel = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: sel ? _C.primary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: sel ? _C.primary : _C.border, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(f,
                              style: TextStyle(
                                  color: sel ? Colors.white : _C.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : _C.bg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${_countOf(f)}',
                                style: TextStyle(
                                    color: sel ? Colors.white : _C.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Không có thông báo',
                        style: TextStyle(color: _C.textSecondary)))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Text(entry.key.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textSecondary,
                                  letterSpacing: 0.5)),
                        ),
                        ...entry.value.map(_card),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(_Noti n) {
    return GestureDetector(
      onTap: () => setState(() => n.read = true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.read ? Colors.white : n.color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: n.color, width: 4),
            top: const BorderSide(color: _C.border),
            right: const BorderSide(color: _C.border),
            bottom: const BorderSide(color: _C.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: n.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.icon, color: n.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary)),
                      ),
                      if (!n.read)
                        Container(
                          width: 9,
                          height: 9,
                          decoration:
                              BoxDecoration(color: n.color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.body,
                      style: const TextStyle(
                          fontSize: 13, color: _C.textSecondary, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(n.time,
                      style: const TextStyle(
                          fontSize: 11,
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

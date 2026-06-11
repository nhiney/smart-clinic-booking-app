import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kết quả xét nghiệm — tóm tắt AI dễ hiểu + chi tiết từng chỉ số có thước đo.
/// Route /lab-results. Dữ liệu demo theo thiết kế.
class LabResultsScreen extends StatelessWidget {
  const LabResultsScreen({super.key});

  static const _primary = Color(0xFF1D4ED8);
  static const _bg = Color(0xFFF8FAFC);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tùy chọn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textPrimary)),
            const SizedBox(height: 16),
            _menuTile(context, Icons.share_rounded, 'Chia sẻ kết quả', const Color(0xFF1D4ED8), () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang chuẩn bị chia sẻ...')),
              );
            }),
            _menuTile(context, Icons.download_rounded, 'Tải PDF', const Color(0xFF10B981), () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải hồ sơ PDF...')),
              );
            }),
            _menuTile(context, Icons.content_copy_rounded, 'Sao chép mã xét nghiệm', const Color(0xFF7C3AED), () {
              Navigator.pop(context);
              Clipboard.setData(const ClipboardData(text: '#XN-23052026-0451'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép mã #XN-23052026-0451')),
              );
            }),
            _menuTile(context, Icons.calendar_month_rounded, 'Đặt lịch tái khám', const Color(0xFFF59E0B), () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((r) => r.isFirst);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển đến trang đặt lịch...')),
                  );
                }
              });
            }),
            _menuTile(context, Icons.flag_outlined, 'Báo kết quả sai', const Color(0xFFEF4444), () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã gửi báo cáo đến hệ thống')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: _textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text('Kết quả xét nghiệm',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('23/05/2026 · 10:42',
                style: TextStyle(
                    color: _primary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          const Text('Xét nghiệm máu\ntổng quát',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                  height: 1.15)),
          const SizedBox(height: 6),
          const Text('BS. Trần Minh Quân · BV Bạch Mai · #XN-23052026-0451',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          _aiSummary(),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip('9', 'Bình thường', _green),
              const SizedBox(width: 10),
              _statChip('2', 'Cảnh báo', _amber),
              const SizedBox(width: 10),
              _statChip('1', 'Nguy hiểm', _red),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Chi tiết chỉ số',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          const Text('TIM MẠCH & MỠ MÁU',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _indexCard('Cholesterol TP', 'Tham chiếu: < 5.2', '6.2', 'mmol/L',
              level: 2, position: 0.78),
          const SizedBox(height: 10),
          _indexCard('LDL-C (xấu)', 'Tham chiếu: < 3.4', '4.1', 'mmol/L',
              level: 2, position: 0.72),
          const SizedBox(height: 10),
          _indexCard('HDL-C (tốt)', 'Tham chiếu: > 1.0', '1.3', 'mmol/L',
              level: 0, position: 0.4),
          const SizedBox(height: 10),
          _indexCard('Đường huyết', 'Tham chiếu: 3.9 - 5.6', '7.1', 'mmol/L',
              level: 3, position: 0.9),
        ],
      ),
    );
  }

  Widget _aiSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text('TÓM TẮT AI · DỄ HIỂU',
                  style: TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 12),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                  color: _textPrimary, fontSize: 14, height: 1.55),
              children: [
                TextSpan(
                    text: '3/12 chỉ số ',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(
                    text:
                        'đang ngoài ngưỡng bình thường. Cholesterol và đường huyết cao hơn mức khuyến nghị. Cần điều chỉnh chế độ ăn và '),
                TextSpan(
                    text: 'tái khám sau 4 tuần.',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// level: 0 = bình thường, 2 = cảnh báo, 3 = nguy hiểm.
  Widget _indexCard(String name, String ref, String value, String unit,
      {required int level, required double position}) {
    final Color valueColor =
        level >= 3 ? _red : (level >= 2 ? _amber : _green);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary)),
                    const SizedBox(height: 2),
                    Text(ref,
                        style: const TextStyle(
                            fontSize: 12, color: _textSecondary)),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: valueColor)),
                  const SizedBox(width: 3),
                  Text(unit,
                      style: const TextStyle(
                          fontSize: 12, color: _textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _gauge(position),
        ],
      ),
    );
  }

  Widget _gauge(double position) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return SizedBox(
          height: 14,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(colors: [
                    _green,
                    _amber,
                    _red,
                  ]),
                ),
              ),
              Positioned(
                left: (w * position).clamp(0, w - 14),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _textPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

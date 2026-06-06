import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';

class DoctorAnalyticsScreen extends StatelessWidget {
  const DoctorAnalyticsScreen({super.key});

  static const _diagnoses = [
    ('Tăng huyết áp (I10)', 72, Color(0xFF1D4ED8)),
    ('Đau thắt ngực (I20)', 48, Color(0xFFEF4444)),
    ('Rối loạn nhịp (I49)', 32, Color(0xFF7C3AED)),
    ('Rối loạn lipid (E78)', 21, Color(0xFF10B981)),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final stats = ctrl.stats;
    final total = stats['today_total'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hiệu suất khám', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('Bạn đang ở top 8% bác sĩ Tim mạch toàn hệ thống',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  _ScoreCard(),
                  const SizedBox(height: 12),
                  _buildMetricsGrid(),
                  const SizedBox(height: 20),
                  const Text('Chẩn đoán phổ biến', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('184 ca tháng này', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 12),
                  _buildDiagnosisChart(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: const Color(0xFF0F172A),
      title: const Text('Phân tích', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0F172A))),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Tháng 5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
          ]),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    const metrics = [
      ('TỔNG CA KHÁM', '184', '+12%', true, Color(0xFF1D4ED8)),
      ('THỜI GIAN TB', '22ph', '-3ph', false, Color(0xFF10B981)),
      ('TỶ LỆ TÁI KHÁM', '68%', '+5%', true, Color(0xFF7C3AED)),
      ('HÀI LÒNG', '4.9★', '+0.1', true, Color(0xFFF59E0B)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: metrics.map((m) => _MetricCard(
        label: m.$1, value: m.$2, change: m.$3,
        isPositive: m.$4, accent: m.$5,
      )).toList(),
    );
  }

  Widget _buildDiagnosisChart() {
    const maxCount = 72;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: _diagnoses.map((d) {
          final fraction = d.$2 / maxCount;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(d.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                  Text('${d.$2} ca', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(d.$3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.94,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Text('94', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1)),
                  Text('ĐIỂM', style: TextStyle(color: Colors.white60, fontSize: 8, letterSpacing: 0.5)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ĐIỂM HIỆU SUẤT', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                const Text('Xuất sắc', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 8),
                const Text('+6 điểm so với tháng trước.\nĐúng giờ & hài lòng cao.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, change;
  final bool isPositive;
  final Color accent;
  const _MetricCard({required this.label, required this.value, required this.change, required this.isPositive, required this.accent});

  @override
  Widget build(BuildContext context) {
    final changeColor = isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final changeBg = isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: changeBg, borderRadius: BorderRadius.circular(4)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 11, color: changeColor),
            const SizedBox(width: 2),
            Text(change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: changeColor)),
          ]),
        ),
      ]),
    );
  }
}

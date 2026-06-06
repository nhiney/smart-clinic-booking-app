import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_workspace_models.dart';

class DoctorIncomeScreen extends StatelessWidget {
  const DoctorIncomeScreen({super.key});

  static const _accent = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(ctrl),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryRow(ctrl),
                const SizedBox(height: 16),
                _buildTrendCard(ctrl),
                const SizedBox(height: 20),
                _buildSectionHeader(),
                const SizedBox(height: 10),
                ...ctrl.incomeEntries.map((e) => _IncomeEntryTile(entry: e)),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(DoctorController ctrl) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: _accent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF065F46), Color(0xFF10B981)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thu nhập', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${ctrl.monthlyIncome.toStringAsFixed(1)}M VNĐ tháng này',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Thu nhập', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      leading: const BackButton(color: Colors.white),
    );
  }

  Widget _buildSummaryRow(DoctorController ctrl) {
    return Row(
      children: [
        _SummaryCard(
          label: 'Tháng này',
          value: '${ctrl.monthlyIncome.toStringAsFixed(1)}M',
          icon: Icons.trending_up_rounded,
          color: _accent,
          bgColor: const Color(0xFFECFDF5),
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Đã nhận',
          value: '${ctrl.receivedIncome.toStringAsFixed(1)}M',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 10),
        _SummaryCard(
          label: 'Chờ xử lý',
          value: '${ctrl.pendingIncome.toStringAsFixed(1)}M',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
        ),
      ],
    );
  }

  Widget _buildTrendCard(DoctorController ctrl) {
    final trend = ctrl.monthlyIncomeTrend;
    final growthPct = trend.length >= 2
        ? ((trend.last - trend.first) / trend.first * 100).toStringAsFixed(1)
        : '0.0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Xu hướng 6 tháng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 14, color: _accent),
                    const SizedBox(width: 4),
                    Text('+$growthPct%', style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('triệu VNĐ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: _TrendChart(data: trend.map((e) => e.toDouble()).toList()),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(trend.length, (i) {
              final months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'];
              final label = i < months.length ? months[i] : 'T${i + 1}';
              return Column(
                children: [
                  Text(trend[i].toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        const Text('Lịch sử thanh toán', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A))),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<double> data;
  const _TrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 80),
      painter: _TrendPainter(data: data),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> data;
  static const _color = Color(0xFF059669);
  const _TrendPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV;
    double norm(double v) => range == 0 ? 0.5 : (v - minV) / range;

    final pts = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - norm(data[i]) * size.height * 0.85 - size.height * 0.05;
      return Offset(x, y);
    });

    final fillPath = Path()..moveTo(pts.first.dx, size.height)..lineTo(pts.first.dx, pts.first.dy);
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    fillPath..lineTo(pts.last.dx, size.height)..close();

    canvas.drawPath(fillPath, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0x40059669), Color(0x00059669)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill);

    canvas.drawPath(linePath, Paint()
      ..color = _color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    canvas.drawCircle(pts.last, 5, Paint()..color = _color);
    canvas.drawCircle(pts.last, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.data != data;
}

class _IncomeEntryTile extends StatelessWidget {
  final DoctorIncomeEntry entry;
  const _IncomeEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isPaid = entry.isPaid;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: isPaid ? const Color(0xFF059669) : const Color(0xFFF59E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(entry.dateLabel, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.amountLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF059669))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

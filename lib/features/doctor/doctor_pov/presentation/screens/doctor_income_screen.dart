import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_workspace_models.dart';

class DoctorIncomeScreen extends StatelessWidget {
  const DoctorIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _HeroCard(ctrl: ctrl)),
          SliverToBoxAdapter(child: _TrendSection(ctrl: ctrl)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thanh toán gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  TextButton(onPressed: () {}, child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PaymentTile(entry: ctrl.incomeEntries[i]),
                childCount: ctrl.incomeEntries.length,
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
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F172A),
      title: const Text('Thu nhập', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0F172A))),
      leading: const BackButton(color: Color(0xFF0F172A)),
      actions: [
        IconButton(icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF0F172A)), onPressed: () {}),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final DoctorController ctrl;
  const _HeroCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)))),
          Positioned(right: 20, bottom: -30,
            child: Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('THU NHẬP THÁNG 5/2026', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('đ${ctrl.monthlyIncome.toStringAsFixed(1)}M',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('+18.4% vs tháng trước', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ĐÃ NHẬN', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('đ${ctrl.receivedIncome.toStringAsFixed(1)}M',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const Text('73 ca', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHỜ CHUYỂN', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('đ${ctrl.pendingIncome.toStringAsFixed(1)}M',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          const Text('24 ca', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  final DoctorController ctrl;
  const _TrendSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final trend = ctrl.monthlyIncomeTrend;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('6 THÁNG GẦN NHẤT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  const Text('đ32.7M / tháng TB', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('6 tháng', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: _BarChart(data: trend, labels: const ['T12', 'T1', 'T2', 'T3', 'T4', 'T5']),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _BarChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxV = data.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final frac = maxV > 0 ? data[i] / maxV : 0.0;
        final isLast = i == data.length - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLast)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF1D4ED8), borderRadius: BorderRadius.circular(4)),
                    child: Text('đ${data[i].toStringAsFixed(1)}M', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: (frac * 48).clamp(4, 48),
                  decoration: BoxDecoration(
                    color: isLast ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i], style: TextStyle(fontSize: 10, color: isLast ? const Color(0xFF1D4ED8) : const Color(0xFF94A3B8), fontWeight: isLast ? FontWeight.w700 : FontWeight.normal)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final DoctorIncomeEntry entry;
  const _PaymentTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(entry.dateLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+đ${entry.amountLabel}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF059669))),
              const SizedBox(height: 4),
              Text(entry.statusLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

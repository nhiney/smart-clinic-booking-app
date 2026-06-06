import 'package:flutter/material.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
}

class _Med {
  final String name;
  final String dose;
  final String schedule; // "1 viên · Sáng 08:00"
  final String note; // "Sau ăn 30 phút"
  final int total;
  final Color color;
  bool taken;
  final bool upcoming;
  final String upcomingAt;

  _Med({
    required this.name,
    required this.dose,
    required this.schedule,
    required this.note,
    required this.total,
    required this.color,
    this.taken = false,
    this.upcoming = false,
    this.upcomingAt = '',
  });
}

/// Lịch uống thuốc — vòng tuân thủ, biểu đồ 7 ngày, đánh dấu đã uống realtime.
/// Route /medication-schedule.
class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late final List<_Med> _meds = [
    _Med(
      name: 'Amlodipine',
      dose: '5mg',
      schedule: '1 viên · Sáng 08:00',
      note: 'Sau ăn 30 phút',
      total: 30,
      color: _C.primary,
      taken: true,
    ),
    _Med(
      name: 'Aspirin',
      dose: '81mg',
      schedule: '1 viên · Tối 20:00',
      note: 'Trước ngủ, sau ăn',
      total: 30,
      color: _C.red,
      upcoming: true,
      upcomingAt: '20:00',
    ),
    _Med(
      name: 'Atorvastatin',
      dose: '20mg',
      schedule: '1 viên · Tối 21:00',
      note: 'Sau ăn',
      total: 30,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  // lịch sử 7 ngày (true = tuân thủ đủ)
  final _week = [true, true, true, true, true, true, false];
  static const _weekLabels = ['T6', 'T7', 'CN', 'T2', 'T3', 'T4', 'T5'];

  int get _takenToday => _meds.where((m) => m.taken).length;
  int get _totalToday => _meds.length;
  double get _adherence => _totalToday == 0 ? 0 : _takenToday / _totalToday;

  void _toggle(_Med m) {
    setState(() => m.taken = !m.taken);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m.taken
            ? 'Đã đánh dấu uống ${m.name}'
            : 'Đã bỏ đánh dấu ${m.name}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        title: const Text('Lịch uống thuốc',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm thuốc mới')),
            ),
            icon: const Icon(Icons.add_rounded, color: _C.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _adherenceCard(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Thuốc đang dùng',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary)),
              const Spacer(),
              Text('${_meds.length} loại · Đợt 23/04 → 23/05',
                  style: const TextStyle(
                      color: _C.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ..._meds.map(_medCard),
        ],
      ),
    );
  }

  Widget _adherenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TUÂN THỦ HÔM NAY',
                        style: TextStyle(
                            color: _C.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '$_takenToday',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: _C.textPrimary)),
                      TextSpan(
                          text: ' / $_totalToday liều',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _C.textSecondary)),
                    ])),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _C.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          _takenToday >= _totalToday
                              ? 'Hoàn thành hôm nay 🎉'
                              : 'Còn ${_totalToday - _takenToday} liều',
                          style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _adherence),
                        duration: const Duration(milliseconds: 500),
                        builder: (_, v, __) => CircularProgressIndicator(
                          value: v,
                          strokeWidth: 9,
                          backgroundColor: _C.border,
                          valueColor: AlwaysStoppedAnimation(
                              _adherence >= 1 ? _C.green : _C.primary),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Text('${(_adherence * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _C.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('7 NGÀY GẦN NHẤT',
                  style: TextStyle(
                      color: _C.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final ok = _week[i];
              final isToday = i == 6;
              return Column(
                children: [
                  Column(
                    children: List.generate(
                        3,
                        (j) => Container(
                              width: 22,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                color: ok
                                    ? _C.green
                                    : (isToday
                                        ? _C.amber
                                        : _C.border),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )),
                  ),
                  const SizedBox(height: 4),
                  Text(_weekLabels[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isToday ? _C.primary : _C.textSecondary)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _medCard(_Med m) {
    final remaining = m.taken ? m.total - 2 : m.total - 1;
    final progress = remaining / m.total;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication_rounded, color: m.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary)),
                        const SizedBox(width: 6),
                        Text('· ${m.dose}',
                            style: const TextStyle(
                                fontSize: 14,
                                color: _C.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(m.schedule,
                        style: const TextStyle(
                            fontSize: 13, color: _C.textSecondary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 13, color: _C.textSecondary),
                        const SizedBox(width: 3),
                        Text(m.note,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _C.textSecondary,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ],
                ),
              ),
              if (m.upcoming && !m.taken)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.white, size: 7),
                      const SizedBox(width: 5),
                      Text('Sắp tới ${m.upcomingAt}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Còn lại',
                  style: TextStyle(fontSize: 12, color: _C.textSecondary)),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: _C.border,
                    valueColor: AlwaysStoppedAnimation(m.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$remaining / ${m.total} viên',
                  style: const TextStyle(
                      fontSize: 12,
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              _markButton(m),
            ],
          ),
        ],
      ),
    );
  }

  Widget _markButton(_Med m) {
    if (m.taken) {
      return GestureDetector(
        onTap: () => _toggle(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _C.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: _C.green, size: 16),
              SizedBox(width: 4),
              Text('Đã uống',
                  style: TextStyle(
                      color: _C.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _toggle(m),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _C.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Đánh dấu',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

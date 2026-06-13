import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';

class DoctorScheduleListScreen extends StatefulWidget {
  const DoctorScheduleListScreen({super.key});

  @override
  State<DoctorScheduleListScreen> createState() => _State();
}

class _State extends State<DoctorScheduleListScreen> {
  static const _weekDayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _filters = ['Tất cả', 'Cấp', 'Lần đầu', 'Tái khám'];

  late DateTime _weekStart;
  int _selectedDay = 0;
  int _filterIndex = 0;
  bool _loading = false;
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final wd = now.weekday; // 1=Mon
    _weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: wd - 1));
    _selectedDay = wd - 1; // 0-indexed, Mon=0
    _fetch();
  }

  DateTime get _selectedDate => _weekStart.add(Duration(days: _selectedDay));

  static List<Map<String, dynamic>> _demoAppointments(DateTime date) {
    final base = DateTime(date.year, date.month, date.day);
    return [
      {'id': 'demo1', 'patientName': 'Nguyễn Thị Mai', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 8))), 'status': 'completed', 'visitType': 'Lần đầu', 'diagnosis': 'Tim mạch'},
      {'id': 'demo2', 'patientName': 'Trần Văn Bình', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 8, minutes: 30))), 'status': 'completed', 'visitType': 'Tái khám', 'diagnosis': 'THA độ 2'},
      {'id': 'demo3', 'patientName': 'Lê Thị Hoa', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 9))), 'status': 'confirmed', 'visitType': 'Lần đầu', 'diagnosis': 'Tiểu đường type 2'},
      {'id': 'demo4', 'patientName': 'Phạm Quốc Toản', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 9, minutes: 30))), 'status': 'confirmed', 'visitType': 'Cấp', 'diagnosis': 'Đau ngực cấp'},
      {'id': 'demo5', 'patientName': 'Võ Minh Tuấn', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 10))), 'status': 'pendingBooking', 'visitType': 'Lần đầu', 'diagnosis': ''},
      {'id': 'demo6', 'patientName': 'Nguyễn Văn An', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 14))), 'status': 'pendingBooking', 'visitType': 'Tái khám', 'diagnosis': 'ĐTN không ổn định'},
      {'id': 'demo7', 'patientName': 'Bùi Thị Lan', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 14, minutes: 30))), 'status': 'pendingBooking', 'visitType': 'Lần đầu', 'diagnosis': ''},
      {'id': 'demo8', 'patientName': 'Đặng Minh Khoa', 'appointmentDate': Timestamp.fromDate(base.add(const Duration(hours: 15))), 'status': 'pendingBooking', 'visitType': 'Tái khám', 'diagnosis': 'Suy tim EF giảm'},
    ];
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final doctor = context.read<DoctorController>().currentDoctor;
      if (doctor == null) {
        setState(() { _appointments = _demoAppointments(_selectedDate); _loading = false; });
        return;
      }
      final dayStart = _selectedDate;
      final dayEnd = dayStart.add(const Duration(days: 1));
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(dayEnd))
          .get();
      var results = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      results.sort((a, b) {
        final ta = a['appointmentDate'];
        final tb = b['appointmentDate'];
        final da = ta is Timestamp ? ta.toDate() : DateTime.now();
        final db = tb is Timestamp ? tb.toDate() : DateTime.now();
        return da.compareTo(db);
      });
      setState(() {
        _appointments = results.isEmpty ? _demoAppointments(_selectedDate) : results;
        _loading = false;
      });
    } catch (_) {
      setState(() { _appointments = _demoAppointments(_selectedDate); _loading = false; });
    }
  }

  void _selectDay(int i) {
    setState(() => _selectedDay = i);
    _fetch();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterIndex == 0) return _appointments;
    final tags = ['', 'Cấp', 'Lần đầu', 'Tái khám'];
    final tag = tags[_filterIndex];
    return _appointments.where((a) => (a['visitType'] ?? '') == tag).toList();
  }

  // group into sessions: morning (before 12), afternoon (12+)
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final morning = <Map<String, dynamic>>[];
    final afternoon = <Map<String, dynamic>>[];
    for (final a in _filtered) {
      final ts = a['appointmentDate'];
      final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
      if (dt.hour < 12) morning.add(a); else afternoon.add(a);
    }
    return {if (morning.isNotEmpty) 'CA SÁNG · 08:00 – 11:30': morning,
            if (afternoon.isNotEmpty) 'CA CHIỀU · 14:00 – 17:00': afternoon};
  }

  int _countByStatus(String s) => _appointments.where((a) => (a['status'] ?? '') == s).length;

  @override
  Widget build(BuildContext context) {
    final total = _appointments.length;
    final done = _countByStatus('completed');
    final inProgress = _countByStatus('confirmed');
    final remaining = total - done - inProgress;
    final weekEnd = _weekStart.add(const Duration(days: 5));
    final weekLabel = 'Tuần ${_weekNumber(_weekStart)} · Tháng ${_weekStart.month}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            elevation: 0,
            title: const Text('Lịch khám', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0F172A))),
            actions: [
              IconButton(icon: const Icon(Icons.search_rounded, color: Color(0xFF0F172A)), onPressed: () {}),
              IconButton(icon: const Icon(Icons.add_rounded, color: Color(0xFF1D4ED8)), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weekLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text('$total ca trong 6 ngày', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const Text(' · ', style: TextStyle(color: Color(0xFF94A3B8))),
                    const Text('+8 vs tuần trước', style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  _buildDayPicker(),
                  const SizedBox(height: 12),
                  _buildStatStrip(total, done, inProgress, remaining),
                  const SizedBox(height: 10),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8)))
            : _buildAppointmentList(),
      ),
    );
  }

  Widget _buildDayPicker() {
    return Row(
      children: List.generate(7, (i) {
        final date = _weekStart.add(Duration(days: i));
        final isSun = i == 6;
        final isSelected = _selectedDay == i;
        // count appointments on this day
        return Expanded(
          child: GestureDetector(
            onTap: isSun ? null : () => _selectDay(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(_weekDayLabels[i],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: isSun ? const Color(0xFFCBD5E1) : isSelected ? Colors.white70 : const Color(0xFF94A3B8))),
                  const SizedBox(height: 4),
                  Text('${date.day}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                          color: isSun ? const Color(0xFFCBD5E1) : isSelected ? Colors.white : const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  // mini appointment badge
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(child: Text('0', style: TextStyle(fontSize: 9, color: isSelected ? Colors.white : const Color(0xFF94A3B8)))),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatStrip(int total, int done, int inProgress, int remaining) {
    return Row(
      children: [
        _StatBox(value: '$total', label: 'Tổng', color: const Color(0xFF0F172A)),
        _StatBox(value: '$done', label: 'Đã xong', color: const Color(0xFF059669)),
        _StatBox(value: '$inProgress', label: 'Đang khám', color: const Color(0xFF1D4ED8)),
        _StatBox(value: '${remaining.clamp(0, 999)}', label: 'Còn lại', color: const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (i) {
          final sel = _filterIndex == i;
          final count = i == 0 ? _appointments.length : _appointments.where((a) {
            final tags = ['', 'Cấp', 'Lần đầu', 'Tái khám'];
            return (a['visitType'] ?? '') == tags[i];
          }).length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1D4ED8) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_filters[i]} $count',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : const Color(0xFF64748B))),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppointmentList() {
    final grouped = _grouped;
    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Không có lịch hẹn hôm nay', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: grouped.entries.expand((entry) => [
        _SessionHeader(label: entry.key),
        ...entry.value.asMap().entries.map((e) => _AppointmentRow(
          appointment: e.value,
          isActive: e.key == entry.value.indexWhere((a) => (a['status'] ?? '') == 'confirmed'),
        )),
      ]).toList(),
    );
  }

  int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final String label;
  const _SessionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.3)),
          GestureDetector(
            onTap: () {},
            child: const Text('Thu gọn', style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isActive;
  const _AppointmentRow({required this.appointment, required this.isActive});

  static const _typeColor = {
    'Tái khám': Color(0xFF1D4ED8),
    'Định kỳ': Color(0xFF059669),
    'Cấp': Color(0xFFDC2626),
    'Lần đầu': Color(0xFF7C3AED),
  };

  @override
  Widget build(BuildContext context) {
    final ts = appointment['appointmentDate'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final name = appointment['patientName'] as String? ?? 'Bệnh nhân';
    final age = appointment['patientAge'] as int? ?? 0;
    final diagnosis = appointment['notes'] as String? ?? '';
    final visitType = appointment['visitType'] as String? ?? '';
    final isDone = (appointment['status'] ?? '') == 'completed';
    final initials = name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join().toUpperCase();
    final typeColor = _typeColor[visitType] ?? const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? const Color(0xFF86EFAC) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 40,
              child: Text(timeStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)))),
            Column(
              children: [
                Container(width: 8, height: 8,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? const Color(0xFF22C55E) : isDone ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                  )),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                    child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                                color: isDone ? const Color(0xFF94A3B8) : const Color(0xFF0F172A)),
                            ),
                          ),
                          if (age > 0) Text(' · ${age}t', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ]),
                        if (diagnosis.isNotEmpty)
                          Text(diagnosis, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Row(children: [
                          if (visitType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(visitType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: typeColor)),
                            ),
                          if (isDone) ...[
                            const SizedBox(width: 8),
                            const Row(children: [
                              Icon(Icons.check_rounded, size: 12, color: Color(0xFF94A3B8)),
                              SizedBox(width: 2),
                              Text('Xong', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            ]),
                          ],
                        ]),
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

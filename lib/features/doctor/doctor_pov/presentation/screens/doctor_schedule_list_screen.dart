import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';

class DoctorScheduleListScreen extends StatefulWidget {
  const DoctorScheduleListScreen({super.key});

  @override
  State<DoctorScheduleListScreen> createState() => _DoctorScheduleListScreenState();
}

class _DoctorScheduleListScreenState extends State<DoctorScheduleListScreen> {
  static const _accent = Color(0xFF7C3AED);
  String _selectedStatus = 'all';
  late DateTime _weekStart;
  bool _isLoading = false;
  List<Map<String, dynamic>> _appointments = [];
  String? _error;

  static const _statuses = [
    ('all', 'Tất cả'),
    ('pending_booking', 'Chờ xác nhận'),
    ('confirmed', 'Đã xác nhận'),
    ('completed', 'Hoàn thành'),
    ('cancelled', 'Đã hủy'),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final doctor = context.read<DoctorController>().currentDoctor;
    if (doctor == null) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final weekEnd = _weekStart.add(const Duration(days: 7));
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(_weekStart))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(weekEnd))
          .orderBy('appointmentDate')
          .get();
      setState(() {
        _appointments = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).update({'status': status});
    _fetchAppointments();
  }

  void _shiftWeek(int delta) {
    setState(() { _weekStart = _weekStart.add(Duration(days: 7 * delta)); });
    _fetchAppointments();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedStatus == 'all') return _appointments;
    return _appointments.where((a) => (a['status'] ?? '') == _selectedStatus).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedByDay {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final a in _filtered) {
      final ts = a['appointmentDate'];
      final date = ts is Timestamp ? ts.toDate() : DateTime.now();
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      (map[key] ??= []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildWeekNav()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverFillRemaining(child: _ErrorView(error: _error!, onRetry: _fetchAppointments))
          else if (_filtered.isEmpty)
            const SliverFillRemaining(child: _EmptyView())
          else
            _buildAppointmentList(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: _accent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch hẹn tuần', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${_appointments.length} lịch hẹn tuần này', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Lịch hẹn', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _fetchAppointments,
        ),
      ],
    );
  }

  Widget _buildWeekNav() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final label = '${_weekStart.day}/${_weekStart.month} – ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _shiftWeek(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: _accent,
          ),
          Expanded(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          IconButton(
            onPressed: () => _shiftWeek(1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: _accent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statuses.map((s) {
            final selected = _selectedStatus == s.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: selected,
                label: Text(s.$2, style: TextStyle(fontSize: 12, color: selected ? Colors.white : const Color(0xFF64748B), fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                onSelected: (_) => setState(() => _selectedStatus = s.$1),
                backgroundColor: Colors.white,
                selectedColor: _accent,
                checkmarkColor: Colors.white,
                side: BorderSide(color: selected ? _accent : const Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverList _buildAppointmentList() {
    final grouped = _groupedByDay;
    final sortedKeys = grouped.keys.toList()..sort();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final key = sortedKeys[i];
          final items = grouped[key]!;
          final parts = key.split('-');
          final dateLabel = '${parts[2]}/${parts[1]}/${parts[0]}';
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DayHeader(label: dateLabel, count: items.length),
                const SizedBox(height: 8),
                ...items.map((a) => _AppointmentCard(appointment: a, accent: _accent, onUpdateStatus: _updateStatus)),
              ],
            ),
          );
        },
        childCount: sortedKeys.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  final int count;
  const _DayHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count lịch', style: const TextStyle(fontSize: 11, color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final Color accent;
  final Future<void> Function(String id, String status) onUpdateStatus;
  const _AppointmentCard({required this.appointment, required this.accent, required this.onUpdateStatus});

  static const _statusConfig = {
    'pending_booking': (Color(0xFFF59E0B), Color(0xFFFEF3C7), 'Chờ xác nhận'),
    'confirmed': (Color(0xFF3B82F6), Color(0xFFEFF6FF), 'Đã xác nhận'),
    'completed': (Color(0xFF10B981), Color(0xFFECFDF5), 'Hoàn thành'),
    'cancelled': (Color(0xFFEF4444), Color(0xFFFEF2F2), 'Đã hủy'),
  };

  @override
  Widget build(BuildContext context) {
    final status = appointment['status'] as String? ?? '';
    final cfg = _statusConfig[status] ?? (const Color(0xFF94A3B8), const Color(0xFFF8FAFC), 'Không rõ');
    final patientName = appointment['patientName'] as String? ?? 'Bệnh nhân';
    final ts = appointment['appointmentDate'];
    final date = ts is Timestamp ? ts.toDate() : DateTime.now();
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final notes = appointment['notes'] as String?;
    final isPending = status == 'pending_booking';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Text(patientName.split(' ').last.substring(0, 1), style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(timeStr, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: cfg.$2, borderRadius: BorderRadius.circular(8)),
                  child: Text(cfg.$3, style: TextStyle(color: cfg.$1, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(notes, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
            if (isPending) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onUpdateStatus(appointment['id'] as String, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onUpdateStatus(appointment['id'] as String, 'confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Xác nhận', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('Không có lịch hẹn trong tuần này', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

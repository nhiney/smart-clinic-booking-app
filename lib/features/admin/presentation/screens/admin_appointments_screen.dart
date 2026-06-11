import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/icare_tokens.dart';
import '../controllers/admin_controller.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  String _statusFilter = 'all';

  static const _filters = [
    ('all', 'Tất cả'),
    ('pending_booking', 'Chờ xác nhận'),
    ('confirmed', 'Đã xác nhận'),
    ('completed', 'Hoàn thành'),
    ('cancelled', 'Đã hủy'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAllAppointments();
    });
  }

  void _applyFilter(String filter) {
    setState(() => _statusFilter = filter);
    context.read<AdminController>().fetchAllAppointments(
      statusFilter: filter == 'all' ? null : filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();
    final appointments = ctrl.allAppointments;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilterChips()),
          if (ctrl.appointmentsLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (appointments.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _AppointmentCard(
                    data: appointments[i],
                    onConfirm: () => _changeStatus(appointments[i]['id'], 'confirmed'),
                    onCancel: () => _changeStatus(appointments[i]['id'], 'cancelled'),
                  ),
                  childCount: appointments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _changeStatus(String id, String status) async {
    await context.read<AdminController>().updateAppointmentStatus(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'confirmed' ? 'Đã xác nhận lịch hẹn' : 'Đã hủy lịch hẹn'),
          backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: IColors.primary500,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1565C0), IColors.primary500],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quản lý lịch hẹn',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Xem và xử lý tất cả lịch hẹn trên hệ thống',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
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
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((f) {
            final selected = _statusFilter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: selected,
                onSelected: (_) => _applyFilter(f.$1),
                selectedColor: IColors.primary500.withValues(alpha: 0.15),
                checkmarkColor: IColors.primary500,
                labelStyle: TextStyle(
                  color: selected ? IColors.primary500 : const Color(0xFF64748B),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(color: selected ? IColors.primary500 : const Color(0xFFE2E8F0)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Không có lịch hẹn', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _AppointmentCard({required this.data, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? 'pending_booking';
    final patientName = data['patientName'] as String? ?? 'Bệnh nhân';
    final doctorName = data['doctorName'] as String? ?? 'Bác sĩ';
    final specialty = data['specialty'] as String? ?? '';
    final rawDate = data['dateTime'];
    DateTime? dt;
    try {
      if (rawDate is String) dt = DateTime.tryParse(rawDate);
      if (rawDate != null && rawDate.runtimeType.toString().contains('Timestamp')) {
        dt = (rawDate as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    final dateStr = dt != null ? DateFormat('dd/MM/yyyy  HH:mm').format(dt) : '—';

    final statusMeta = _statusMeta(status);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: IColors.primary500.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: IColors.primary500, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('BS. $doctorName${specialty.isNotEmpty ? '  •  $specialty' : ''}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(dateStr, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusMeta.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusMeta.$1, style: TextStyle(color: statusMeta.$2, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (status == 'pending_booking' || status == 'pending')
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Hủy lịch', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Xác nhận', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  (String, Color) _statusMeta(String status) {
    switch (status) {
      case 'confirmed': return ('Đã xác nhận', Colors.green);
      case 'completed': return ('Hoàn thành', const Color(0xFF6366F1));
      case 'cancelled': return ('Đã hủy', Colors.red);
      case 'checked_in': return ('Đã check-in', Colors.orange);
      case 'in_consultation': return ('Đang khám', Colors.blue);
      default: return ('Chờ xác nhận', Colors.orange);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _tabIndex = 0;

  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _tabIndex,
          children: [
            _buildDashboard(context),
            _placeholderTab(context, 'Lịch khám'),
            _placeholderTab(context, 'Bệnh án'),
            _placeholderTab(context, 'Cá nhân'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: const Color(0xFF1D5FD3),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Lịch khám'),
          BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'Bệnh án'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final doctorName = 'Dr. Nguyễn Văn An';
    final hospital = 'BV Đa khoa ICare';
    final department = 'Khoa Nội';

    final stats = const <_StatItem>[
      _StatItem(title: 'Số bệnh nhân hôm nay', value: '18', icon: Icons.groups_rounded, color: Color(0xFF0EA5E9)),
      _StatItem(title: 'Lịch khám hôm nay', value: '12', icon: Icons.calendar_today_rounded, color: Color(0xFF1D5FD3)),
      _StatItem(title: 'Đang chờ khám', value: '4', icon: Icons.hourglass_top_rounded, color: Color(0xFFF59E0B)),
    ];

    final quickActions = <_QuickAction>[
      const _QuickAction('Xem lịch khám', Icons.calendar_month_rounded),
      const _QuickAction('Xác nhận lịch', Icons.verified_rounded),
      const _QuickAction('Khám bệnh', Icons.medical_services_rounded),
      const _QuickAction('Hồ sơ bệnh nhân', Icons.folder_shared_rounded),
      const _QuickAction('Video call', Icons.video_call_rounded),
      const _QuickAction('Chat', Icons.chat_bubble_rounded),
    ];

    final todayAppointments = const <_AppointmentItem>[
      _AppointmentItem(patientName: 'Trần Minh Khôi', time: '08:30', status: 'chờ'),
      _AppointmentItem(patientName: 'Nguyễn Thị Lan', time: '09:15', status: 'đã xác nhận'),
      _AppointmentItem(patientName: 'Lê Quốc Huy', time: '10:00', status: 'chờ'),
      _AppointmentItem(patientName: 'Phạm Thu Trang', time: '10:45', status: 'đã xác nhận'),
    ];

    return ListView(
      padding: EdgeInsets.all(context.spacing.l),
      children: [
        _HeaderCard(
          doctorName: doctorName,
          hospital: hospital,
          department: department,
        ),
        SizedBox(height: context.spacing.l),

        Text('Tổng quan', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
        SizedBox(height: context.spacing.s),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _StatCard(item: stats[i]),
          ),
        ),

        SizedBox(height: context.spacing.l),
        Text('Thao tác nhanh', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
        SizedBox(height: context.spacing.s),
        LayoutBuilder(
          builder: (context, c) {
            final crossAxisCount = c.maxWidth >= 520 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quickActions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) => _QuickActionTile(action: quickActions[i]),
            );
          },
        ),

        SizedBox(height: context.spacing.l),
        Row(
          children: [
            Expanded(
              child: Text('Lịch hôm nay', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
            ),
            TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
          ],
        ),
        Column(
          children: todayAppointments.map((a) => _AppointmentTile(item: a)).toList(),
        ),

        SizedBox(height: context.spacing.l),
        Text('Bệnh án', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
        SizedBox(height: context.spacing.s),
        _MedicalRecordCard(
          diagnosisController: _diagnosisController,
          prescriptionController: _prescriptionController,
        ),

        SizedBox(height: context.spacing.l),
        Text('Tính năng nâng cao', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
        SizedBox(height: context.spacing.s),
        _TwoButtonRow(
          left: _ActionButtonData('AI hỗ trợ chẩn đoán', Icons.auto_awesome_rounded, onTap: () {}),
          right: _ActionButtonData('Rating bệnh nhân', Icons.star_rounded, onTap: () {}),
        ),
        const SizedBox(height: 12),
        _TwoButtonRow(
          left: _ActionButtonData('Dashboard analytics', Icons.query_stats_rounded, onTap: () {}),
          right: _ActionButtonData('Quản lý thời gian', Icons.schedule_rounded, onTap: () {}),
        ),

        SizedBox(height: context.spacing.l),
        Text('Quản lý khối lượng công việc', style: context.textStyles.heading3.copyWith(color: const Color(0xFF0F172A))),
        SizedBox(height: context.spacing.s),
        const _WorkloadCard(
          dailyLimit: 25,
          breakTime: '12:00 – 13:30',
          scheduleStrategy: 'Ưu tiên tái khám & khung giờ cố định',
        ),
      ],
    );
  }

  Widget _placeholderTab(BuildContext context, String title) {
    return Center(
      child: Text(title, style: context.textStyles.heading2),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String doctorName;
  final String hospital;
  final String department;

  const _HeaderCard({
    required this.doctorName,
    required this.hospital,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D5FD3), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: context.textStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$hospital • $department',
                  style: context.textStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6EEF7)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.title, style: context.textStyles.bodySmall.copyWith(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(item.value, style: context.textStyles.heading2.copyWith(color: const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  const _QuickAction(this.title, this.icon);
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EEF7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1D5FD3).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: const Color(0xFF1D5FD3), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action.title,
                style: context.textStyles.bodyBold.copyWith(fontSize: 14, color: const Color(0xFF0F172A)),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _AppointmentItem {
  final String patientName;
  final String time;
  final String status; // 'chờ' | 'đã xác nhận'
  const _AppointmentItem({
    required this.patientName,
    required this.time,
    required this.status,
  });
}

class _AppointmentTile extends StatelessWidget {
  final _AppointmentItem item;
  const _AppointmentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isWaiting = item.status.toLowerCase().contains('chờ');
    final statusColor = isWaiting ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final statusBg = statusColor.withValues(alpha: 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEF7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0EA5E9).withValues(alpha: 0.14),
            child: const Icon(Icons.person_rounded, color: Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.patientName, style: context.textStyles.bodyBold.copyWith(color: const Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.black45),
                    const SizedBox(width: 6),
                    Text(item.time, style: context.textStyles.bodySmall.copyWith(color: Colors.black54)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.status,
                        style: context.textStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5FD3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Khám', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final TextEditingController diagnosisController;
  final TextEditingController prescriptionController;

  const _MedicalRecordCard({
    required this.diagnosisController,
    required this.prescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, IconData icon) => InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEF7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: diagnosisController,
            maxLines: 2,
            decoration: deco('Chẩn đoán', Icons.monitor_heart_rounded),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: prescriptionController,
            maxLines: 3,
            decoration: deco('Đơn thuốc', Icons.medication_rounded),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Ký số'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Gửi đơn thuốc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload kết quả'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonData {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButtonData(this.text, this.icon, {required this.onTap});
}

class _TwoButtonRow extends StatelessWidget {
  final _ActionButtonData left;
  final _ActionButtonData right;
  const _TwoButtonRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    Widget button(_ActionButtonData data) {
      return Expanded(
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6EEF7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D5FD3).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: const Color(0xFF1D5FD3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.text,
                    style: context.textStyles.bodyBold.copyWith(color: const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        button(left),
        const SizedBox(width: 12),
        button(right),
      ],
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  final int dailyLimit;
  final String breakTime;
  final String scheduleStrategy;

  const _WorkloadCard({
    required this.dailyLimit,
    required this.breakTime,
    required this.scheduleStrategy,
  });

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, IconData icon) {
      return Row(
        children: [
          Icon(icon, color: const Color(0xFF1D5FD3), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: context.textStyles.bodySmall.copyWith(color: Colors.black54))),
          Text(value, style: context.textStyles.bodyBold.copyWith(color: const Color(0xFF0F172A))),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEF7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          row('Số bệnh nhân/ngày (limit)', '$dailyLimit', Icons.people_alt_rounded),
          const SizedBox(height: 10),
          row('Lịch nghỉ (break time)', breakTime, Icons.free_breakfast_rounded),
          const SizedBox(height: 10),
          row('Phân bổ lịch khám', scheduleStrategy, Icons.tune_rounded),
        ],
      ),
    );
  }
}


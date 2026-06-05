import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

enum SlotStatus { done, current, next, upcoming }

enum AppointmentType { emergency, firstVisit, followUp, online }

class AppointmentSlot {
  final String time;
  final AppointmentType type;
  final SlotStatus status;
  final String patientName;
  final String age;
  final String note;
  final bool isUrgent;
  final bool isTelemedicine;
  final String duration;
  final int elapsedMinutes; // only for current

  const AppointmentSlot({
    required this.time,
    required this.type,
    required this.status,
    required this.patientName,
    required this.age,
    required this.note,
    this.isUrgent = false,
    this.isTelemedicine = false,
    this.duration = '30m',
    this.elapsedMinutes = 0,
  });
}

class DayItem {
  final String dayName;
  final int date;
  final int count;
  final bool isToday;
  final bool isSunday;

  const DayItem({
    required this.dayName,
    required this.date,
    required this.count,
    this.isToday = false,
    this.isSunday = false,
  });
}

// ─── Hardcoded Data ──────────────────────────────────────────────────────────

const _days = [
  DayItem(dayName: 'T2', date: 19, count: 8),
  DayItem(dayName: 'T3', date: 20, count: 5),
  DayItem(dayName: 'T4', date: 21, count: 11, isToday: true),
  DayItem(dayName: 'T5', date: 22, count: 9),
  DayItem(dayName: 'T6', date: 23, count: 6),
  DayItem(dayName: 'T7', date: 24, count: 4),
  DayItem(dayName: 'CN', date: 25, count: 0, isSunday: true),
];

const _morningSlots = [
  AppointmentSlot(
    time: '07:30',
    type: AppointmentType.emergency,
    status: SlotStatus.done,
    patientName: 'Nguyễn Văn An',
    age: '45t',
    note: 'Đau ngực cấp, nhồi máu cơ tim nghi ngờ',
    isUrgent: true,
  ),
  AppointmentSlot(
    time: '08:10',
    type: AppointmentType.followUp,
    status: SlotStatus.done,
    patientName: 'Trần Thị Bình',
    age: '62t',
    note: 'Tăng huyết áp, kiểm tra định kỳ',
  ),
  AppointmentSlot(
    time: '08:45',
    type: AppointmentType.firstVisit,
    status: SlotStatus.done,
    patientName: 'Lê Minh Châu',
    age: '38t',
    note: 'Đau ngực, cần đánh giá nguyên nhân',
  ),
  AppointmentSlot(
    time: '09:20',
    type: AppointmentType.followUp,
    status: SlotStatus.current,
    patientName: 'Phạm Quốc Đại',
    age: '55t',
    note: 'Theo dõi sau đặt stent động mạch vành',
    elapsedMinutes: 8,
    duration: '08 phút',
  ),
  AppointmentSlot(
    time: '10:00',
    type: AppointmentType.firstVisit,
    status: SlotStatus.next,
    patientName: 'Hoàng Thị Em',
    age: '71t',
    note: 'Khó thở khi gắng sức, mệt mỏi',
  ),
  AppointmentSlot(
    time: '10:40',
    type: AppointmentType.online,
    status: SlotStatus.upcoming,
    patientName: 'Vũ Hải Phong',
    age: '42t',
    note: 'Tư vấn kết quả xét nghiệm tim mạch',
    isTelemedicine: true,
  ),
  AppointmentSlot(
    time: '11:15',
    type: AppointmentType.emergency,
    status: SlotStatus.upcoming,
    patientName: 'Đỗ Minh Khoa',
    age: '29t',
    note: 'Rối loạn nhịp tim, chóng mặt đột ngột',
    isUrgent: true,
  ),
];

const _afternoonSlots = [
  AppointmentSlot(
    time: '13:30',
    type: AppointmentType.firstVisit,
    status: SlotStatus.upcoming,
    patientName: 'Bùi Thị Lan',
    age: '58t',
    note: 'Siêu âm tim, đánh giá van tim',
  ),
  AppointmentSlot(
    time: '14:00',
    type: AppointmentType.online,
    status: SlotStatus.upcoming,
    patientName: 'Ngô Văn Minh',
    age: '34t',
    note: 'Hỏi về đơn thuốc và cách dùng',
    isTelemedicine: true,
  ),
  AppointmentSlot(
    time: '14:40',
    type: AppointmentType.followUp,
    status: SlotStatus.upcoming,
    patientName: 'Cao Thị Nga',
    age: '66t',
    note: 'Tái khám sau đặt stent 6 tháng',
  ),
  AppointmentSlot(
    time: '15:20',
    type: AppointmentType.followUp,
    status: SlotStatus.upcoming,
    patientName: 'Trịnh Hoàng Oanh',
    age: '49t',
    note: 'Huyết áp định kỳ, điều chỉnh thuốc',
  ),
];

const _filterLabels = ['Tất cả', 'Cấp cứu', 'Lần đầu', 'Tái khám', 'Online'];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _selectedDay = 2; // T4 index (today)
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      floatingActionButton: _buildFab(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildDayPicker()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildStatsGrid()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildFilterChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildSectionHeader('CA SÁNG · 07:30 – 11:30', IColors.primary500)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ..._morningSlots.map((s) => SliverToBoxAdapter(child: _SlotCard(slot: s))),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildSectionHeader('CA CHIỀU · 13:30 – 16:30', IColors.warning)),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ..._afternoonSlots.map((s) => SliverToBoxAdapter(child: _SlotCard(slot: s))),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  void _showDoctorMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: IColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: IColors.line, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.calendar_today_rounded, color: IColors.primary500),
            title: const Text('Lịch khám của tôi'),
            onTap: () { Navigator.pop(context); GoRouter.of(context).push('/doctor/schedule'); },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: IColors.primary500),
            title: const Text('Thông báo'),
            onTap: () { Navigator.pop(context); GoRouter.of(context).push('/notifications'); },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: IColors.primary500),
            title: const Text('Hỗ trợ & Trợ giúp'),
            onTap: () { Navigator.pop(context); GoRouter.of(context).push('/support'); },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: IColors.ink3),
            title: const Text('Cài đặt'),
            onTap: () { Navigator.pop(context); GoRouter.of(context).push('/notifications/settings'); },
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THÁNG 5, 2026',
                  style: TextStyle(
                    fontFamily: IFont.inter,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: IColors.primary500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Lịch khám', style: IText.display(size: 24)),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => GoRouter.of(context).push('/notifications'),
                icon: const Icon(Icons.notifications_outlined, size: 24, color: IColors.ink),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: IColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        fontFamily: IFont.inter,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _showDoctorMenu(context),
            icon: const Icon(Icons.more_vert_rounded, size: 22, color: IColors.ink2),
          ),
        ],
      ),
    );
  }

  // ── 7-Day Picker ─────────────────────────────────────────────────────────
  Widget _buildDayPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Row(
          children: List.generate(_days.length, (i) {
            final day = _days[i];
            final isSelected = _selectedDay == i;
            return Expanded(child: _DayCell(
              day: day,
              isSelected: isSelected,
              onTap: day.isSunday ? null : () => setState(() => _selectedDay = i),
            ));
          }),
        ),
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    const stats = [
      _StatData('Tổng lịch', '11', Icons.calendar_month_rounded, IColors.primary500, IColors.primary50),
      _StatData('Đã xong', '3', Icons.check_circle_rounded, IColors.success, IColors.successBg),
      _StatData('Đang khám', '1', Icons.radio_button_checked, IColors.warning, IColors.warningBg),
      _StatData('Còn lại', '7', Icons.schedule_rounded, IColors.ink, IColors.line2),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats
            .map((s) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StatTile(data: s),
                )))
            .toList()
          ..[3] = Expanded(child: _StatTile(data: stats[3])),
      ),
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? IColors.ink : IColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? IColors.ink : IColors.line,
                ),
              ),
              child: Text(
                _filterLabels[i],
                style: TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : IColors.ink2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String label, Color barColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: IFont.interTight,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: IColors.ink2,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IColors.primary500, IColors.primary700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: IColors.primary500.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => GoRouter.of(context).push('/doctor/schedule'),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thêm lịch',
                  style: TextStyle(
                    fontFamily: IFont.interTight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Day Cell ────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DayItem day;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DayCell({required this.day, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textColor = day.isSunday
        ? IColors.danger.withValues(alpha: 0.5)
        : isSelected
            ? Colors.white
            : IColors.ink;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Today dot indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: (day.isToday && !isSelected) ? IColors.primary500 : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? IColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  day.dayName,
                  style: TextStyle(
                    fontFamily: IFont.inter,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: day.isSunday
                        ? IColors.danger.withValues(alpha: 0.45)
                        : isSelected
                            ? Colors.white.withValues(alpha: 0.7)
                            : IColors.ink3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${day.date}',
                  style: TextStyle(
                    fontFamily: IFont.interTight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Count badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : day.count > 0
                            ? IColors.primary50
                            : IColors.line2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${day.count}',
                    style: TextStyle(
                      fontFamily: IFont.inter,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : day.count > 0
                              ? IColors.primary500
                              : IColors.ink3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Data & Tile ─────────────────────────────────────────────────────────

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconBg;

  const _StatData(this.label, this.value, this.icon, this.color, this.iconBg);
}

class _StatTile extends StatelessWidget {
  final _StatData data;

  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, size: 16, color: data.color),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: IText.num(size: 20, color: data.color, weight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              fontFamily: IFont.inter,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: IColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot Card ────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  final AppointmentSlot slot;

  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: IColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: slot.status == SlotStatus.current
                    ? IColors.warning.withValues(alpha: 0.4)
                    : IColors.line,
                width: slot.status == SlotStatus.current ? 1.5 : 1,
              ),
              boxShadow: slot.status == SlotStatus.current
                  ? [
                      BoxShadow(
                        color: IColors.warning.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                      ...IColors.cardShadow,
                    ]
                  : IColors.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusColumn(slot: slot),
                    Expanded(child: _CardContent(slot: slot)),
                  ],
                ),
              ),
            ),
          ),
          // Urgent ribbon
          if (slot.isUrgent)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: IColors.danger,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'KHẨN',
                      style: TextStyle(
                        fontFamily: IFont.inter,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Status Column ────────────────────────────────────────────────────────────

class _StatusColumn extends StatelessWidget {
  final AppointmentSlot slot;

  const _StatusColumn({required this.slot});

  Color get _bgColor {
    switch (slot.status) {
      case SlotStatus.done:
        return IColors.line2;
      case SlotStatus.current:
        return IColors.warningBg;
      case SlotStatus.next:
        return IColors.primary50;
      case SlotStatus.upcoming:
        return IColors.surface;
    }
  }

  Color get _timeColor {
    switch (slot.status) {
      case SlotStatus.done:
        return IColors.ink3;
      case SlotStatus.current:
        return IColors.warning;
      case SlotStatus.next:
        return IColors.primary500;
      case SlotStatus.upcoming:
        return IColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      color: _bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slot.time,
            style: TextStyle(
              fontFamily: IFont.interTight,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: _timeColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          _buildIndicator(),
          const SizedBox(height: 6),
          Text(
            slot.status == SlotStatus.current ? slot.duration : slot.duration,
            style: TextStyle(
              fontFamily: IFont.inter,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: _timeColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    switch (slot.status) {
      case SlotStatus.done:
        return Icon(Icons.check_circle_rounded, size: 18, color: IColors.ink3.withValues(alpha: 0.6));
      case SlotStatus.current:
        return _PulsingDot();
      case SlotStatus.next:
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: IColors.primary500,
            shape: BoxShape.circle,
          ),
        );
      case SlotStatus.upcoming:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: IColors.ink200, width: 2),
          ),
        );
    }
  }
}

// ─── Pulsing Dot ──────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: IColors.warning,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: IColors.warning.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Content ─────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  final AppointmentSlot slot;

  const _CardContent({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, slot.isUrgent ? 20 : 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            children: [
              Expanded(
                child: Text(
                  slot.patientName,
                  style: const TextStyle(
                    fontFamily: IFont.interTight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: IColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              _TypeBadge(type: slot.type),
              if (slot.isTelemedicine) ...[
                const SizedBox(width: 4),
                _VideoPill(),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // Age + note
          Text(
            '${slot.age} · ${slot.note}',
            style: const TextStyle(
              fontFamily: IFont.inter,
              fontSize: 12,
              color: IColors.ink3,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Status row
          _StatusRow(slot: slot),
        ],
      ),
    );
  }
}

// ─── Type Badge ───────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final AppointmentType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (type) {
      AppointmentType.emergency => ('Cấp cứu', IColors.dangerBg, IColors.danger),
      AppointmentType.firstVisit => ('Lần đầu', IColors.primary50, IColors.primary500),
      AppointmentType.followUp => ('Tái khám', IColors.mintBg, IColors.mint),
      AppointmentType.online => ('Online', IColors.violetBg, IColors.violet),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: IFont.inter,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Video Pill ───────────────────────────────────────────────────────────────

class _VideoPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: IColors.violetBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_rounded, size: 10, color: IColors.violet),
          SizedBox(width: 3),
          Text(
            'VIDEO',
            style: TextStyle(
              fontFamily: IFont.inter,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: IColors.violet,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Row ───────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final AppointmentSlot slot;

  const _StatusRow({required this.slot});

  @override
  Widget build(BuildContext context) {
    switch (slot.status) {
      case SlotStatus.done:
        return Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 12, color: IColors.success),
            const SizedBox(width: 4),
            const Text(
              'ĐÃ HOÀN THÀNH',
              style: TextStyle(
                fontFamily: IFont.inter,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: IColors.success,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => GoRouter.of(context).push('/medical-records'),
              child: const Text(
                'Xem hồ sơ →',
                style: TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: IColors.primary500,
                ),
              ),
            ),
          ],
        );

      case SlotStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: IColors.warningBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: IColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Đang khám · ${slot.elapsedMinutes} phút đã trôi qua',
                style: const TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: IColors.warning,
                ),
              ),
            ],
          ),
        );

      case SlotStatus.next:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: IColors.primary50,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'TIẾP THEO',
                style: TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: IColors.primary500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => GoRouter.of(context).push('/doctor/schedule'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: IColors.primary100),
                ),
                child: const Text(
                  'Mời vào',
                  style: TextStyle(
                    fontFamily: IFont.inter,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: IColors.primary500,
                  ),
                ),
              ),
            ),
          ],
        );

      case SlotStatus.upcoming:
        return Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: IColors.ink3.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'SẮP TỚI',
              style: TextStyle(
                fontFamily: IFont.inter,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: IColors.ink3,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => GoRouter.of(context).push('/appointments'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: IColors.line2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: IColors.line),
                ),
                child: const Text(
                  'Chi tiết',
                  style: TextStyle(
                    fontFamily: IFont.inter,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: IColors.ink2,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

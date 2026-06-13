import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';
import '../../domain/entities/doctor_schedule_slot.dart';
import '../riverpod/doctor_schedule_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Doctor → Lịch khám — Full Timeline Screen (Doctor's POV)
// ═══════════════════════════════════════════════════════════════════════════

class DoctorScheduleTimelineScreen extends ConsumerStatefulWidget {
  const DoctorScheduleTimelineScreen({super.key});

  @override
  ConsumerState<DoctorScheduleTimelineScreen> createState() =>
      _DoctorScheduleTimelineScreenState();
}

class _DoctorScheduleTimelineScreenState
    extends ConsumerState<DoctorScheduleTimelineScreen> {
  late DateTime _selectedDate;
  int _selectedFilter = 0;
  late List<DateTime> _weekDays;

  final _filters = ['Tất cả', 'Cấp cứu', 'Lần đầu', 'Tái khám', 'Online'];

  @override
  void initState() {
    super.initState();
    _selectedDate = _startOfDay(DateTime.now());
    _weekDays = _buildWeek(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorScheduleProvider.notifier).loadForDay(_selectedDate);
    });
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  List<DateTime> _buildWeek(DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _selectDay(DateTime date) {
    if (date.weekday == DateTime.sunday) return;
    setState(() => _selectedDate = date);
    ref.read(doctorScheduleProvider.notifier).loadForDay(date);
  }

  List<DoctorScheduleSlot> _filtered(List<DoctorScheduleSlot> slots) {
    if (_selectedFilter == 0) return slots;
    final type = [
      null,
      ScheduleSlotType.urgent,
      ScheduleSlotType.first,
      ScheduleSlotType.revisit,
      ScheduleSlotType.online,
    ][_selectedFilter];
    return slots.where((s) => s.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(doctorScheduleProvider);
    final filtered = _filtered(scheduleState.slots);

    final morningSlots = filtered
        .where((s) => s.dateTime.hour < 12)
        .toList();
    final afternoonSlots = filtered
        .where((s) => s.dateTime.hour >= 12)
        .toList();

    final doneCount = scheduleState.slots
        .where((s) => s.status == ScheduleSlotStatus.done)
        .length;
    final currentCount = scheduleState.slots
        .where((s) => s.status == ScheduleSlotStatus.current)
        .length;
    final remainingCount = scheduleState.slots
        .where((s) =>
            s.status == ScheduleSlotStatus.upcoming ||
            s.status == ScheduleSlotStatus.next)
        .length;

    final stats = [
      (label: 'Tổng lịch', value: '${scheduleState.slots.length}', color: IColors.primary500, bg: IColors.primary50, icon: Icons.calendar_today_rounded),
      (label: 'Đã xong', value: '$doneCount', color: IColors.success, bg: IColors.successBg, icon: Icons.check_circle_rounded),
      (label: 'Đang khám', value: '$currentCount', color: IColors.warning, bg: IColors.warningBg, icon: Icons.person_rounded),
      (label: 'Còn lại', value: '$remainingCount', color: IColors.ink, bg: IColors.line2, icon: Icons.pending_rounded),
    ];

    return Scaffold(
      backgroundColor: IColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDayPicker(),
            Expanded(
              child: scheduleState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : scheduleState.error != null
                      ? _buildError(scheduleState.error!)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          children: [
                            _buildStatsGrid(stats),
                            const SizedBox(height: 16),
                            _buildFilterChips(),
                            const SizedBox(height: 20),
                            if (morningSlots.isNotEmpty) ...[
                              _buildSection('CA SÁNG · 07:30 – 11:30', morningSlots),
                              const SizedBox(height: 20),
                            ],
                            if (afternoonSlots.isNotEmpty)
                              _buildSection('CA CHIỀU · 13:30 – 16:30', afternoonSlots),
                            if (morningSlots.isEmpty && afternoonSlots.isEmpty)
                              _buildEmpty(),
                          ],
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDay,
        backgroundColor: IColors.primary500,
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
        label: Text('Chọn ngày',
            style: IText.body(
                size: 13, weight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  /// Pick a day and reload the schedule for it.
  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now.add(const Duration(days: 120)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: IColors.primary500),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      ref.read(doctorScheduleProvider.notifier).loadForDay(picked);
    }
  }

  /// Show the details of a single appointment slot.
  void _showSlotDetail(DoctorScheduleSlot slot) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: IColors.line2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(slot.patientName,
                style: IText.display(size: 18, color: IColors.ink)),
            const SizedBox(height: 8),
            _detailRow(Icons.schedule_rounded,
                '${DateFormat('dd/MM/yyyy').format(slot.dateTime)} · '
                '${DateFormat.Hm().format(slot.dateTime)} (${slot.durationMinutes} phút)'),
            if (slot.isVideo)
              _detailRow(Icons.videocam_rounded, 'Khám video từ xa'),
            if (slot.isUrgent)
              _detailRow(Icons.priority_high_rounded, 'Ưu tiên/khẩn'),
            if (slot.note.isNotEmpty)
              _detailRow(Icons.notes_rounded, slot.note),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context.push('/medical-records');
                },
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Xem hồ sơ bệnh án'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: IColors.primary500),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: IText.body(size: 13, color: IColors.ink2))),
        ]),
      );

  Widget _buildError(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: IColors.danger),
            const SizedBox(height: 12),
            Text('Không tải được lịch khám',
                style: IText.body(
                    size: 15, weight: FontWeight.w600, color: IColors.ink)),
            const SizedBox(height: 6),
            Text(message,
                style: IText.body(size: 12, color: IColors.ink3),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => ref
                  .read(doctorScheduleProvider.notifier)
                  .loadForDay(_selectedDate),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: IColors.primary500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Thử lại',
                    style: IText.body(
                        size: 13, weight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      );

  Widget _buildEmpty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.event_available_rounded,
                size: 56, color: IColors.ink200),
            const SizedBox(height: 12),
            Text('Không có lịch khám',
                style: IText.body(
                    size: 15, weight: FontWeight.w600, color: IColors.ink3)),
          ]),
        ),
      );

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final months = [
      '', 'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6',
      'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${months[_selectedDate.month]}, ${_selectedDate.year}',
                    style: IText.label(color: IColors.primary500)),
                const SizedBox(height: 4),
                Text('Lịch khám',
                    style: IText.display(size: 24, color: IColors.ink)),
              ],
            ),
          ),
          _iconBtn(Icons.notifications_outlined, () {}, badge: null),
          const SizedBox(width: 8),
          _iconBtn(Icons.refresh_rounded,
              () => ref.read(doctorScheduleProvider.notifier).loadForDay(DateTime.now())),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {String? badge}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IColors.line),
              boxShadow: IColors.cardShadow,
            ),
            child: Icon(icon, size: 20, color: IColors.ink),
          ),
        ),
        if (badge != null)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: IColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: IColors.bg, width: 1.5)),
              child: Center(
                  child: Text(badge,
                      style: const TextStyle(
                          fontFamily: IFont.inter,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white))),
            ),
          ),
      ],
    );
  }

  // ─── Day Picker ──────────────────────────────────────────────────────────────
  Widget _buildDayPicker() {
    final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = _startOfDay(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Row(
          children: _weekDays.indexed.map((e) {
            final i = e.$1;
            final d = e.$2;
            final isSunday = d.weekday == DateTime.sunday;
            final isToday = d == today;
            final sel = d == _selectedDate;

            return Expanded(
              child: GestureDetector(
                onTap: isSunday ? null : () => _selectDay(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? IColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isToday && !sel)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: IColors.primary500,
                              shape: BoxShape.circle),
                        )
                      else
                        const SizedBox(height: 5),
                      const SizedBox(height: 3),
                      Text(dayNames[i],
                          style: IText.label(
                            size: 9.5,
                            color: sel
                                ? Colors.white60
                                : isSunday
                                    ? IColors.danger.withValues(alpha: 0.4)
                                    : IColors.ink3,
                          )),
                      const SizedBox(height: 3),
                      Text('${d.day}',
                          style: IText.num(
                            size: 15,
                            weight: FontWeight.w800,
                            color: sel
                                ? Colors.white
                                : isSunday
                                    ? IColors.ink200
                                    : IColors.ink,
                          )),
                      const SizedBox(height: 4),
                      if (!isSunday)
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: sel
                                ? Colors.white.withValues(alpha: 0.2)
                                : IColors.primary50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              d == _selectedDate
                                  ? '${ref.watch(doctorScheduleProvider).slots.length}'
                                  : '·',
                              style: IText.num(
                                size: 9.5,
                                weight: FontWeight.w800,
                                color: sel
                                    ? Colors.white
                                    : IColors.primary500,
                              ),
                            ),
                          ),
                        )
                      else
                        Text('–',
                            style: IText.label(size: 10, color: IColors.ink200)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Stats Grid ──────────────────────────────────────────────────────────────
  Widget _buildStatsGrid(List stats) {
    return Row(
      children: stats.indexed.map((e) {
        final i = e.$1;
        final s = e.$2 as ({String label, String value, Color color, Color bg, IconData icon});
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < stats.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(12),
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
                      color: s.bg,
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(s.icon, color: s.color, size: 16),
                ),
                const SizedBox(height: 8),
                Text(s.value,
                    style: IText.num(
                        size: 20, weight: FontWeight.w800, color: s.color)),
                const SizedBox(height: 2),
                Text(s.label,
                    style: IText.label(size: 9.5, color: IColors.ink3)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? IColors.ink : IColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: sel ? IColors.ink : IColors.line),
              ),
              child: Center(
                  child: Text(_filters[i],
                      style: IText.body(
                          size: 12.5,
                          weight: FontWeight.w600,
                          color: sel ? Colors.white : IColors.ink2))),
            ),
          );
        },
      ),
    );
  }

  // ─── Schedule Section ─────────────────────────────────────────────────────────
  Widget _buildSection(String title, List<DoctorScheduleSlot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [IColors.primary500, IColors.primary700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: IText.label(size: 11, color: IColors.ink2)),
          const Spacer(),
          Text('${slots.length} lịch',
              style: IText.label(size: 10.5, color: IColors.ink3)),
        ]),
        const SizedBox(height: 12),
        ...slots.map((s) => _buildSlotCard(s)),
      ],
    );
  }

  Widget _buildSlotCard(DoctorScheduleSlot slot) {
    final typeConfig = _typeConfig(slot.type);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: IColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: slot.status == ScheduleSlotStatus.current
                  ? IColors.warning.withValues(alpha: 0.5)
                  : slot.status == ScheduleSlotStatus.next
                      ? IColors.primary500.withValues(alpha: 0.4)
                      : IColors.line,
              width: slot.status == ScheduleSlotStatus.current ? 1.5 : 1.0,
            ),
            boxShadow: slot.status == ScheduleSlotStatus.current
                ? [
                    BoxShadow(
                        color: IColors.warning.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]
                : slot.status == ScheduleSlotStatus.next
                    ? [
                        BoxShadow(
                            color: IColors.primary500.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : IColors.cardShadow,
          ),
          child: Row(
            children: [
              // Time + status column
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _statusBg(slot.status),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(slot.formattedTime,
                        style: IText.num(
                          size: 12.5,
                          weight: FontWeight.w800,
                          color: _statusTimeColor(slot.status),
                        )),
                    const SizedBox(height: 6),
                    _statusDot(slot.status),
                    const SizedBox(height: 4),
                    Text(slot.formattedDuration,
                        style: IText.label(
                            size: 9.5,
                            color: _statusTimeColor(slot.status)
                                .withValues(alpha: 0.7))),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(
                          slot.patientName,
                          style: IText.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: slot.status == ScheduleSlotStatus.done
                                ? IColors.ink3
                                : IColors.ink,
                          ),
                        )),
                        if (slot.isVideo)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: IColors.violetBg,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color:
                                      IColors.violet.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.videocam_rounded,
                                      size: 11, color: IColors.violet),
                                  const SizedBox(width: 4),
                                  Text('VIDEO',
                                      style: IText.label(
                                          size: 9, color: IColors.violet)),
                                ]),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeConfig.$1,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(typeConfig.$2,
                              style: IText.label(
                                  size: 9.5, color: typeConfig.$3)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      if (slot.note.isNotEmpty)
                        Text(slot.note,
                            style: IText.body(
                              size: 12,
                              color: slot.status == ScheduleSlotStatus.done
                                  ? IColors.ink3
                                  : IColors.ink2,
                            )),
                      _buildStatusRow(slot),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // "KHẨN" ribbon for urgent
        if (slot.isUrgent)
          Positioned(
            left: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomRight: Radius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                color: IColors.danger,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text('KHẨN', style: IText.label(size: 9, color: Colors.white)),
                ]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusRow(DoctorScheduleSlot slot) {
    switch (slot.status) {
      case ScheduleSlotStatus.current:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: IColors.warningBg,
              borderRadius: BorderRadius.circular(9),
              border:
                  Border.all(color: IColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.timer_rounded, size: 13, color: IColors.warning),
              const SizedBox(width: 6),
              Text('Đang khám · ${slot.formattedDuration} đã trôi qua',
                  style: IText.body(
                      size: 11.5,
                      weight: FontWeight.w600,
                      color: IColors.warning)),
              const Spacer(),
              GestureDetector(
                onTap: () => ref
                    .read(doctorScheduleProvider.notifier)
                    .updateStatus(slot.id, ScheduleSlotStatus.done),
                child: Text('Hoàn thành →',
                    style: IText.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: IColors.success)),
              ),
            ]),
          ),
        );
      case ScheduleSlotStatus.next:
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            const Icon(Icons.navigate_next_rounded,
                size: 14, color: IColors.primary500),
            Text('TIẾP THEO',
                style: IText.label(size: 9.5, color: IColors.primary500)),
            const Spacer(),
            GestureDetector(
              onTap: () => ref
                  .read(doctorScheduleProvider.notifier)
                  .updateStatus(slot.id, ScheduleSlotStatus.current),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: IColors.primary100),
                ),
                child: Text('Mời vào',
                    style: IText.body(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: IColors.primary500)),
              ),
            ),
          ]),
        );
      case ScheduleSlotStatus.done:
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                size: 13, color: IColors.success),
            const SizedBox(width: 4),
            Text('ĐÃ HOÀN THÀNH',
                style: IText.label(size: 9.5, color: IColors.success)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showSlotDetail(slot),
              child: Text('Xem hồ sơ →',
                  style: IText.body(
                      size: 11.5,
                      weight: FontWeight.w600,
                      color: IColors.primary500)),
            ),
          ]),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: IColors.ink200, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text('SẮP TỚI',
                style: IText.label(size: 9.5, color: IColors.ink3)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showSlotDetail(slot),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: IColors.line2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Chi tiết',
                    style: IText.body(
                        size: 11, weight: FontWeight.w600, color: IColors.ink2)),
              ),
            ),
          ]),
        );
    }
  }

  Color _statusBg(ScheduleSlotStatus s) {
    switch (s) {
      case ScheduleSlotStatus.done:
        return IColors.line2;
      case ScheduleSlotStatus.current:
        return IColors.warningBg;
      case ScheduleSlotStatus.next:
        return IColors.primary50;
      case ScheduleSlotStatus.upcoming:
        return IColors.surface;
    }
  }

  Color _statusTimeColor(ScheduleSlotStatus s) {
    switch (s) {
      case ScheduleSlotStatus.done:
        return IColors.ink3;
      case ScheduleSlotStatus.current:
        return IColors.warning;
      case ScheduleSlotStatus.next:
        return IColors.primary500;
      case ScheduleSlotStatus.upcoming:
        return IColors.ink;
    }
  }

  Widget _statusDot(ScheduleSlotStatus s) {
    switch (s) {
      case ScheduleSlotStatus.done:
        return const Icon(Icons.check_circle_rounded,
            size: 14, color: IColors.success);
      case ScheduleSlotStatus.current:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: IColors.warning,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: IColors.warning.withValues(alpha: 0.5), blurRadius: 6),
              BoxShadow(
                  color: IColors.warning.withValues(alpha: 0.2),
                  blurRadius: 14),
            ],
          ),
        );
      case ScheduleSlotStatus.next:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: IColors.primary500,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: IColors.primary500.withValues(alpha: 0.4),
                  blurRadius: 8)
            ],
          ),
        );
      case ScheduleSlotStatus.upcoming:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: IColors.ink200, width: 2),
          ),
        );
    }
  }

  (Color, String, Color) _typeConfig(ScheduleSlotType t) {
    switch (t) {
      case ScheduleSlotType.urgent:
        return (IColors.dangerBg, 'Cấp cứu', IColors.danger);
      case ScheduleSlotType.first:
        return (IColors.primary50, 'Lần đầu', IColors.primary500);
      case ScheduleSlotType.revisit:
        return (IColors.mintBg, 'Tái khám', IColors.mint);
      case ScheduleSlotType.online:
        return (IColors.violetBg, 'Online', IColors.violet);
    }
  }
}

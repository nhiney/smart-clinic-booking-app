import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/icare_tokens.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/appointment_entity.dart';
import '../controllers/appointment_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _selectedTab = _tabController.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context
            .read<AppointmentController>()
            .loadAppointments(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);
  String _formatShortDate(DateTime dt) => DateFormat('dd MMM').format(dt);
  String _formatDayName(DateTime dt) => DateFormat('EEEE', 'vi').format(dt);

  String _doctorInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'BS';
  }

  String _countdown(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Đã qua';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _statusLabel(String status) {
    switch (AppointmentStatuses.normalize(status)) {
      case AppointmentStatuses.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatuses.booked:
        return 'Đã đặt';
      case AppointmentStatuses.pendingBooking:
        return 'Chờ xác nhận';
      case AppointmentStatuses.checkedIn:
        return 'Đã check-in';
      case AppointmentStatuses.inQueue:
        return 'Đang chờ khám';
      case AppointmentStatuses.inConsultation:
        return 'Đang khám';
      case AppointmentStatuses.rescheduled:
        return 'Đã đổi lịch';
      case AppointmentStatuses.completed:
        return 'Hoàn thành';
      case AppointmentStatuses.cancelled:
        return 'Đã hủy';
      case AppointmentStatuses.noShow:
        return 'Vắng mặt';
      default:
        return status;
    }
  }

  bool _isConfirmed(String status) {
    final n = AppointmentStatuses.normalize(status);
    return n == AppointmentStatuses.confirmed ||
        n == AppointmentStatuses.checkedIn ||
        n == AppointmentStatuses.inQueue ||
        n == AppointmentStatuses.inConsultation;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: Consumer<AppointmentController>(
        builder: (_, controller, __) {
          final upcoming = controller.upcomingAppointments;
          final completed = controller.completedAppointments;
          final cancelled = controller.cancelledAppointments;

          return Column(
            children: [
              _buildHeader(upcoming.length, completed.length, cancelled.length),
              _buildGreetingBlock(upcoming.length),
              _buildMiniStats(
                total: controller.appointments.length,
                doctors: controller.appointments
                    .map((a) => a.doctorId)
                    .toSet()
                    .length,
              ),
              _buildSegmentedTabBar(
                upcoming.length,
                completed.length,
                cancelled.length,
              ),
              Expanded(
                child: controller.isLoading
                    ? const LoadingWidget(itemCount: 3)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUpcomingTab(upcoming, controller),
                          _buildCompletedTab(completed),
                          _buildCancelledTab(cancelled),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  void _showSearchSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: IColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: IColors.line, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Tìm lịch hẹn', style: IText.body(size: 16, weight: FontWeight.w700, color: IColors.ink)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            autofocus: true,
            style: IText.body(size: 14, color: IColors.ink),
            decoration: InputDecoration(
              hintText: 'Tên bác sĩ hoặc chuyên khoa...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: IColors.ink3),
              filled: true,
              fillColor: IColors.line2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onSubmitted: (v) {
              Navigator.pop(context);
              context.push('/doctor/search', extra: {'query': v});
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(int upCount, int doneCount, int cancelCount) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: IColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: IColors.line, width: 1),
                  boxShadow: const [IColors.shadow1],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: IColors.ink),
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                'Lịch hẹn',
                style: IText.display(size: 22),
              ),
            ),
            // Search icon
            GestureDetector(
              onTap: () => _showSearchSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: IColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: IColors.line, width: 1),
                  boxShadow: const [IColors.shadow1],
                ),
                child: const Icon(Icons.search_rounded,
                    size: 20, color: IColors.ink2),
              ),
            ),
            const SizedBox(width: 8),
            // Plus FAB — đặt lịch mới
            GestureDetector(
              onTap: () => context.push('/doctor/search'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [IColors.primary500, IColors.primary700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: IColors.primary500.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    size: 22, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Greeting Block ────────────────────────────────────────────────────────

  Widget _buildGreetingBlock(int upcomingCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 116,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IColors.navy, IColors.navyMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: IColors.elevatedShadow,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SẮP TỚI TRONG TUẦN NÀY',
                  style: IText.label(size: 10.5, color: Colors.white60),
                ),
                const SizedBox(height: 5),
                Text(
                  '$upcomingCount lịch khám',
                  style: IText.display(size: 24, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  upcomingCount > 0
                      ? 'Nhớ đến đúng giờ để không mất lượt nhé!'
                      : 'Bạn chưa có lịch khám nào sắp tới.',
                  style: IText.body(
                    size: 12.5,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mini Stats Row ────────────────────────────────────────────────────────

  Widget _buildMiniStats({required int total, required int doctors}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _statTile(
            icon: Icons.calendar_month_rounded,
            iconColor: IColors.primary500,
            iconBg: IColors.primary50,
            value: '$total',
            label: 'Tổng năm nay',
          ),
          const SizedBox(width: 10),
          _statTile(
            icon: Icons.medical_services_rounded,
            iconColor: IColors.mint,
            iconBg: IColors.mintBg,
            value: '$doctors',
            label: 'Bác sĩ',
          ),
          const SizedBox(width: 10),
          _statTile(
            icon: Icons.star_rounded,
            iconColor: IColors.amber,
            iconBg: IColors.amberBg,
            value: '4.8',
            label: 'TB đánh giá',
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IColors.line, width: 1),
          boxShadow: const [IColors.shadow1],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: IText.num(size: 14, weight: FontWeight.w700, color: IColors.ink)),
                  Text(label, style: IText.label(size: 10, color: IColors.ink3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Segmented Tab Bar ────────────────────────────────────────────────────

  Widget _buildSegmentedTabBar(int up, int done, int cancel) {
    final labels = ['Sắp tới', 'Hoàn thành', 'Đã hủy'];
    final counts = [up, done, cancel];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: IColors.line2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(3, (i) {
            final isActive = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(i);
                  setState(() => _selectedTab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isActive ? IColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: IColors.ink.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: labels[i],
                            style: TextStyle(
                              fontFamily: IFont.inter,
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive ? IColors.ink : IColors.ink3,
                            ),
                          ),
                          if (counts[i] > 0)
                            TextSpan(
                              text: '  ${counts[i]}',
                              style: TextStyle(
                                fontFamily: IFont.interTight,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isActive
                                    ? IColors.primary500
                                    : IColors.ink3,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Tab: Sắp tới ─────────────────────────────────────────────────────────

  Widget _buildUpcomingTab(
    List<AppointmentEntity> list,
    AppointmentController controller,
  ) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'Chưa có lịch hẹn sắp tới',
        subtitle: 'Đặt lịch khám để theo dõi tình trạng sức khoẻ của bạn.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _AppointmentCardPremium(
        appointment: list[i],
        formatDate: _formatDate,
        formatTime: _formatTime,
        formatShortDate: _formatShortDate,
        formatDayName: _formatDayName,
        doctorInitials: _doctorInitials,
        countdown: _countdown,
        statusLabel: _statusLabel,
        isConfirmed: _isConfirmed,
        onCancel: () => _showCancelDialog(controller, list[i].id),
      ),
    );
  }

  // ─── Tab: Hoàn thành ──────────────────────────────────────────────────────

  Widget _buildCompletedTab(List<AppointmentEntity> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline_rounded,
        title: 'Chưa có lịch hẹn hoàn thành',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: list.length,
      itemBuilder: (ctx, i) =>
          _buildCompletedCard(list[i]),
    );
  }

  Widget _buildCompletedCard(AppointmentEntity a) {
    final initials = _doctorInitials(a.doctorName);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line, width: 1),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(
        children: [
          // Icon tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: IColors.successBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: IText.num(
                    size: 14,
                    weight: FontWeight.w800,
                    color: IColors.success),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.doctorName,
                    style: IText.body(
                        size: 13.5, weight: FontWeight.w700, color: IColors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(a.specialty,
                    style: IText.label(size: 11, color: IColors.ink3)),
                const SizedBox(height: 4),
                Text(_formatDate(a.dateTime),
                    style: IText.body(size: 12, color: IColors.ink2)),
                const SizedBox(height: 6),
                // Stars
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                    size: 13,
                    color: IColors.amber,
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Đã khám',
                  style: IText.label(size: 10, color: IColors.success)),
              const SizedBox(height: 12),
              _smallButton(
                label: 'Xem hồ sơ',
                bg: IColors.primary50,
                fg: IColors.primary500,
              ),
              const SizedBox(height: 6),
              _smallButton(
                label: 'Đặt lại',
                bg: IColors.successBg,
                fg: IColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab: Đã hủy ──────────────────────────────────────────────────────────

  Widget _buildCancelledTab(List<AppointmentEntity> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.cancel_outlined,
        title: 'Chưa có lịch hẹn đã hủy',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildCancelledCard(list[i]),
    );
  }

  Widget _buildCancelledCard(AppointmentEntity a) {
    final initials = _doctorInitials(a.doctorName);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line, width: 1),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: IColors.dangerBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: IText.num(
                    size: 14,
                    weight: FontWeight.w800,
                    color: IColors.danger),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.doctorName,
                    style: IText.body(
                        size: 13.5, weight: FontWeight.w700, color: IColors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(a.specialty,
                    style: IText.label(size: 11, color: IColors.ink3)),
                const SizedBox(height: 4),
                Text(_formatDate(a.dateTime),
                    style: IText.body(size: 12, color: IColors.ink2)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const IPill.danger('Đã hủy'),
              const SizedBox(height: 12),
              _smallButton(
                label: 'Đặt lại',
                bg: IColors.primary50,
                fg: IColors.primary500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _smallButton({
    required String label,
    required Color bg,
    required Color fg,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: IText.label(size: 10.5, color: fg),
        ),
      ),
    );
  }

  // ─── Cancel dialog ────────────────────────────────────────────────────────

  void _showCancelDialog(AppointmentController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy lịch hẹn?'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              controller.cancelAppointment(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: IColors.danger),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AppointmentCardPremium — Inline widget for upcoming appointments
// ═══════════════════════════════════════════════════════════════════════════

class _AppointmentCardPremium extends StatelessWidget {
  final AppointmentEntity appointment;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;
  final String Function(DateTime) formatShortDate;
  final String Function(DateTime) formatDayName;
  final String Function(String) doctorInitials;
  final String Function(DateTime) countdown;
  final String Function(String) statusLabel;
  final bool Function(String) isConfirmed;
  final VoidCallback onCancel;

  const _AppointmentCardPremium({
    required this.appointment,
    required this.formatDate,
    required this.formatTime,
    required this.formatShortDate,
    required this.formatDayName,
    required this.doctorInitials,
    required this.countdown,
    required this.statusLabel,
    required this.isConfirmed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final normalizedStatus = AppointmentStatuses.normalize(a.status);
    final confirmed = isConfirmed(a.status);
    final isCancellable =
        AppointmentStatuses.cancellable.contains(normalizedStatus);
    final cdText = countdown(a.dateTime);
    final isPast = a.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IColors.line, width: 1),
        boxShadow: IColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Date stripe header ───────────────────────────────────────────
          Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [IColors.navy, IColors.navyMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Glass date block
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatShortDate(a.dateTime),
                              style: IText.num(
                                  size: 14,
                                  weight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                            Text(
                              formatDayName(a.dateTime),
                              style: IText.label(
                                  size: 9,
                                  color: Colors.white
                                      .withValues(alpha: 0.75)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Doctor info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.doctorName.isNotEmpty
                                  ? a.doctorName
                                  : 'Bác sĩ',
                              style: IText.body(
                                  size: 14,
                                  weight: FontWeight.w700,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.specialty.isNotEmpty
                                  ? a.specialty
                                  : 'Chuyên khoa',
                              style: IText.label(
                                  size: 10,
                                  color: Colors.white
                                      .withValues(alpha: 0.75)),
                            ),
                            const SizedBox(height: 4),
                            // Time pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 10,
                                      color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatTime(a.dateTime),
                                    style: IText.num(
                                        size: 11,
                                        weight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Countdown ribbon
                      if (!isPast)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                IColors.primary500,
                                IColors.navyMid
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('⏱',
                                  style: TextStyle(fontSize: 12)),
                              Text(
                                cdText,
                                style: IText.num(
                                    size: 11,
                                    weight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Location row ─────────────────────────────────────────────────
          Container(
            color: IColors.line2,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 14, color: IColors.ink3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    a.queueNumber != null
                        ? 'Phòng khám · STT #${a.queueNumber}'
                        : 'Phòng khám · Chờ cấp số',
                    style: IText.body(size: 12, color: IColors.ink2),
                  ),
                ),
              ],
            ),
          ),

          // ── Pills + fee row ──────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Status pill
                confirmed
                    ? const IPill.success('Đã xác nhận',
                        icon: Icons.check_circle_rounded)
                    : const IPill.warning('Chờ xác nhận',
                        icon: Icons.schedule_rounded),
                const SizedBox(width: 6),
                // Payment status badge
                if (a.paymentStatus == AppointmentPaymentStatuses.paid)
                  const IPill.ink('BHYT'),
                const Spacer(),
                Text(
                  a.paymentStatus == AppointmentPaymentStatuses.paid
                      ? 'Miễn phí'
                      : 'Chờ thanh toán',
                  style: IText.num(size: 12, color: IColors.ink2),
                ),
              ],
            ),
          ),

          // ── Footer dark card ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: IColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // STT chip glass
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.queueNumber != null ? '#${a.queueNumber}' : '--',
                    style: IText.mono(size: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                // Wait time
                Expanded(
                  child: Text(
                    a.estimatedWaitTimeMinutes != null
                        ? '~${a.estimatedWaitTimeMinutes} phút chờ'
                        : '~18 phút chờ',
                    style: IText.body(
                        size: 12,
                        color:
                            Colors.white.withValues(alpha: 0.70)),
                  ),
                ),
                // QR icon button
                GestureDetector(
                  onTap: () => context.push('/clinic/scanner',
                      extra: {'appointmentId': 'apt_001'}),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_rounded,
                        size: 17, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                // Chỉ đường button
                GestureDetector(
                  onTap: () => context.push('/maps'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [IColors.primary500, IColors.navyMid],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Chỉ đường →',
                      style: IText.label(size: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Cancel button ─────────────────────────────────────────────────
          if (isCancellable)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: IColors.danger,
                  side: BorderSide(
                      color: IColors.danger.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Text(
                  'Hủy lịch hẹn',
                  style: IText.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: IColors.danger),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

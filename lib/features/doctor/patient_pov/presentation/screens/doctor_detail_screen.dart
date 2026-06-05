import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import "package:smart_clinic_booking/shared/di/injection.dart";

import '../../../../../core/theme/icare_tokens.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_catalog_doctor_detail_usecase.dart';

// ─── Booking tab state helpers ─────────────────────────────────────────
enum _ServiceType { direct, online, message }

class _SlotInfo {
  final String time;
  final bool taken;
  _SlotInfo(this.time, {this.taken = false});
}

class DoctorDetailScreen extends StatefulWidget {
  final DoctorEntity? doctor;
  final String? doctorId;

  const DoctorDetailScreen({
    super.key,
    this.doctor,
    this.doctorId,
  }) : assert(doctor != null || doctorId != null,
            'Either doctor or doctorId must be provided');

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with TickerProviderStateMixin {
  late DoctorEntity _doctor;
  bool _loading = true;
  String? _error;

  // ── Tab controller ──────────────────────────────────────────────────
  late final TabController _tabController;

  // ── Booking tab state ───────────────────────────────────────────────
  _ServiceType _selectedService = _ServiceType.direct;
  int _selectedDayIndex = 0;
  String? _selectedSlot;

  // ── Mock date strip (6 days starting today) ────────────────────────
  final List<DateTime> _days = List.generate(
    6,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  // ── Mock slot data ──────────────────────────────────────────────────
  final List<_SlotInfo> _morningSlots = [
    _SlotInfo('07:30'),
    _SlotInfo('08:00', taken: true),
    _SlotInfo('08:30'),
    _SlotInfo('09:00'),
    _SlotInfo('09:30', taken: true),
    _SlotInfo('10:00'),
    _SlotInfo('10:30'),
    _SlotInfo('11:00', taken: true),
  ];

  final List<_SlotInfo> _afternoonSlots = [
    _SlotInfo('13:00', taken: true),
    _SlotInfo('13:30'),
    _SlotInfo('14:00'),
    _SlotInfo('14:30'),
    _SlotInfo('15:00', taken: true),
    _SlotInfo('15:30'),
    _SlotInfo('16:00'),
    _SlotInfo('16:30'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.doctor != null) {
      _doctor = widget.doctor!;
    } else {
      _doctor = DoctorEntity(
        id: widget.doctorId!,
        name: '',
        specialty: '',
      );
    }
    _hydrateFromRemote();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _hydrateFromRemote() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh =
          await getIt<GetCatalogDoctorDetailUseCase>().call(_doctor.id);
      if (!mounted) return;
      if (fresh != null) {
        setState(() => _doctor = fresh);
      }
    } catch (e) {
      if (!mounted) return;
      if (e is FirebaseException) {
        _error = e.message ?? e.code;
      } else {
        _error = e.toString();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  String get _titleName =>
      _doctor.name.isNotEmpty ? _doctor.name : 'Bác sĩ';

  String get _specialtyLabel {
    final s = _doctor.specialty.isNotEmpty ? _doctor.specialty : 'Chuyên khoa';
    return '${s.toUpperCase()} · CHUYÊN KHOA II';
  }

  String get _servicePriceLabel {
    switch (_selectedService) {
      case _ServiceType.direct:
        return '350.000đ';
      case _ServiceType.online:
        return '250.000đ';
      case _ServiceType.message:
        return '120.000đ';
    }
  }

  String _dayName(DateTime d) {
    const names = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return names[d.weekday % 7];
  }

  String _shortMonth(DateTime d) => '${d.day}/${d.month}';

  String? get _ctaTimeLabel {
    if (_selectedSlot == null) return null;
    final d = _days[_selectedDayIndex];
    return '${_dayName(d)}, ${_shortMonth(d)} · $_selectedSlot';
  }

  // ── Avatar initials ──────────────────────────────────────────────────
  String get _initials {
    final parts = _doctor.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'BS';
  }

  // ════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (ctx, innerScrolled) => [
              _buildHeroHeader(),
              _buildStickyTabBar(),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingTab(),
                _buildAboutTab(),
                _buildReviewTab(),
                _buildArticlesTab(),
              ],
            ),
          ),
          // Sticky bottom CTA (always visible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomCTA(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // HERO HEADER
  // ════════════════════════════════════════════════════════════════════
  Widget _buildHeroHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [IColors.primary100, IColors.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top action row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _circleBtn(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (_error != null)
                      _circleBtn(
                        icon: Icons.refresh,
                        onTap: _hydrateFromRemote,
                      ),
                    const SizedBox(width: 8),
                    _circleBtn(
                      icon: Icons.favorite_border_rounded,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm bác sĩ vào danh sách yêu thích'), duration: Duration(seconds: 2)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _circleBtn(
                      icon: Icons.ios_share_rounded,
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: 'Hãy xem bác sĩ này trên Smart Clinic!'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép thông tin bác sĩ'), duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (_loading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: IColors.primary500,
                  backgroundColor: IColors.primary100,
                ),

              // Error banner
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Không tải được thông tin mới nhất: $_error',
                    style: IText.label(color: IColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 8),

              // Avatar + verified badge
              _buildHeroAvatar(),

              const SizedBox(height: 12),

              // Specialty label
              Text(
                _specialtyLabel,
                style: IText.label(color: IColors.primary700, size: 11),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Doctor name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _titleName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: IFont.interTight,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: IColors.ink,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Hospital + experience
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  [
                    if (_doctor.displayClinic.isNotEmpty) _doctor.displayClinic,
                    if (_doctor.experience > 0) '${_doctor.experience} năm KN',
                  ].join(' · ').isNotEmpty
                      ? [
                          if (_doctor.displayClinic.isNotEmpty)
                            _doctor.displayClinic,
                          if (_doctor.experience > 0)
                            '${_doctor.experience} năm KN',
                        ].join(' · ')
                      : 'Bệnh viện đang cập nhật',
                  textAlign: TextAlign.center,
                  style: IText.body(size: 13, color: IColors.ink3),
                ),
              ),

              const SizedBox(height: 12),

              // Pills row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rating amber pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: IColors.amberBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: IColors.amber),
                        const SizedBox(width: 4),
                        Text(
                          _doctor.rating > 0
                              ? _doctor.rating.toStringAsFixed(1)
                              : '—',
                          style: IText.label(color: IColors.amber, size: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Open slot pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: IColors.successBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: IColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('Đang mở slot',
                            style: IText.label(color: IColors.success, size: 11)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 4 stats grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _statCard(
                      value: _doctor.totalReviews > 0
                          ? '${_doctor.totalReviews}'
                          : '—',
                      label: 'Bệnh nhân',
                      icon: Icons.people_alt_outlined,
                      color: IColors.primary500,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      value: _doctor.experience > 0
                          ? '${_doctor.experience}'
                          : '—',
                      label: 'Năm KN',
                      icon: Icons.work_history_outlined,
                      color: IColors.violet,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      value: _doctor.rating > 0
                          ? '${(_doctor.rating / 5 * 100).toInt()}%'
                          : '—',
                      label: 'Hài lòng',
                      icon: Icons.sentiment_satisfied_alt_outlined,
                      color: IColors.success,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      value: '350K',
                      label: 'Phí khám',
                      icon: Icons.payments_outlined,
                      color: IColors.amber,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroAvatar() {
    final url = _doctor.imageUrl;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow shadow
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: IColors.primary500.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        // White border ring
        Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [IColors.navy, IColors.primary700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: url.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: IFont.interTight,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontFamily: IFont.interTight,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // Verified badge
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: IColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              value,
              style: IText.num(size: 14, weight: FontWeight.w800, color: IColors.ink),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: IText.label(color: IColors.ink3, size: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: IColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Icon(icon, size: 18, color: IColors.ink2),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // STICKY TAB BAR
  // ════════════════════════════════════════════════════════════════════
  Widget _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: IColors.ink, width: 2.5),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: IColors.ink,
          unselectedLabelColor: IColors.ink3,
          labelStyle: const TextStyle(
            fontFamily: IFont.inter,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: IFont.inter,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            const Tab(text: 'Đặt lịch'),
            const Tab(text: 'Giới thiệu'),
            Tab(
              text: _doctor.totalReviews > 0
                  ? 'Đánh giá (${_doctor.totalReviews})'
                  : 'Đánh giá',
            ),
            const Tab(text: 'Bài viết'),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // TAB: ĐẶT LỊCH (index 0, default)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildBookingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        // ── Service selection ────────────────────────────────────────
        _sectionLabel('Loại dịch vụ'),
        const SizedBox(height: 10),
        _buildServiceSelector(),

        const SizedBox(height: 20),

        // ── Date picker ──────────────────────────────────────────────
        _sectionLabel('Chọn ngày'),
        const SizedBox(height: 10),
        _buildDatePicker(),

        const SizedBox(height: 20),

        // ── Time slots ───────────────────────────────────────────────
        _sectionLabel('Khung giờ sáng'),
        const SizedBox(height: 10),
        _buildSlotGrid(_morningSlots),

        const SizedBox(height: 16),

        _sectionLabel('Khung giờ chiều'),
        const SizedBox(height: 10),
        _buildSlotGrid(_afternoonSlots),

        const SizedBox(height: 20),

        // ── Notes ────────────────────────────────────────────────────
        _sectionLabel('Ghi chú cho bác sĩ'),
        const SizedBox(height: 10),
        _buildNotesField(),
      ],
    );
  }

  Widget _buildServiceSelector() {
    final services = [
      (
        type: _ServiceType.direct,
        icon: Icons.local_hospital_outlined,
        label: 'Khám trực tiếp',
        price: '350.000đ',
        color: IColors.primary500,
      ),
      (
        type: _ServiceType.online,
        icon: Icons.videocam_outlined,
        label: 'Trực tuyến',
        price: '250.000đ',
        color: IColors.violet,
      ),
      (
        type: _ServiceType.message,
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Tin nhắn',
        price: '120.000đ',
        color: IColors.mint,
      ),
    ];

    return Column(
      children: services.map((s) {
        final selected = _selectedService == s.type;
        return GestureDetector(
          onTap: () => setState(() => _selectedService = s.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? s.color.withValues(alpha: 0.06)
                  : IColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? s.color : IColors.line,
                width: selected ? 1.8 : 1,
              ),
              boxShadow: selected ? [] : IColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.icon, color: s.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label,
                          style: IText.body(
                              size: 13.5,
                              weight: FontWeight.w600,
                              color: IColors.ink)),
                      Text(s.price, style: IText.label(color: IColors.ink3)),
                    ],
                  ),
                ),
                // Radio dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? s.color : IColors.ink200,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (ctx, i) {
          final d = _days[i];
          final isToday = i == 0;
          final selected = _selectedDayIndex == i;
          // dot color: today=primary, i%3==0=warning, else success (mock)
          Color dotColor;
          if (i % 4 == 3) {
            dotColor = IColors.danger;
          } else if (i % 3 == 2) {
            dotColor = IColors.warning;
          } else {
            dotColor = IColors.success;
          }

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDayIndex = i;
              _selectedSlot = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: selected ? IColors.primary500 : IColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? IColors.primary500 : IColors.line,
                ),
                boxShadow: selected ? [] : IColors.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(d),
                    style: IText.label(
                      color: selected ? Colors.white70 : IColors.ink3,
                      size: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontFamily: IFont.interTight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : IColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // availability dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isToday && !selected)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: IColors.primary500.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white54 : dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotGrid(List<_SlotInfo> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: slots.length,
      itemBuilder: (ctx, i) {
        final slot = slots[i];
        final isSelected = _selectedSlot == slot.time;
        Color bg;
        Color fg;
        Color borderColor;
        if (slot.taken) {
          bg = IColors.line2;
          fg = IColors.ink200;
          borderColor = IColors.line;
        } else if (isSelected) {
          bg = IColors.primary500;
          fg = Colors.white;
          borderColor = IColors.primary500;
        } else {
          bg = IColors.surface;
          fg = IColors.ink;
          borderColor = IColors.line;
        }

        return GestureDetector(
          onTap: slot.taken
              ? null
              : () => setState(() => _selectedSlot = slot.time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(
                slot.time,
                style: TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TextField(
      maxLines: 3,
      style: IText.body(size: 13.5, color: IColors.ink),
      decoration: InputDecoration(
        hintText: 'Mô tả triệu chứng hoặc yêu cầu đặc biệt…',
        hintStyle: IText.body(size: 13, color: IColors.ink3),
        filled: true,
        fillColor: IColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: IColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: IColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: IColors.primary500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // TAB: GIỚI THIỆU (index 1)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // About card
        _buildAboutCard(),
        const SizedBox(height: 14),
        // Hospital card
        _buildHospitalCard(),
        const SizedBox(height: 14),
        // Schedule
        _sectionLabel('Lịch làm việc'),
        const SizedBox(height: 10),
        _buildScheduleWidget(),
      ],
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: IColors.primary500, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Về bác sĩ',
                  style: IText.sectionTitle(color: IColors.ink)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _doctor.about.isNotEmpty
                ? _doctor.about
                : 'Chưa có thông tin giới thiệu về bác sĩ này.',
            style: IText.body(size: 13.5, color: IColors.ink2),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_outlined,
                    color: IColors.primary500, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _doctor.displayClinic.isNotEmpty
                          ? _doctor.displayClinic
                          : 'Đang cập nhật',
                      style:
                          IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink),
                    ),
                    if (_doctor.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: IColors.ink3),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(_doctor.location,
                                style: IText.body(
                                    size: 12.5, color: IColors.ink3)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // BHYT strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: IColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 16, color: IColors.success),
                const SizedBox(width: 8),
                Text('Hỗ trợ thanh toán BHYT',
                    style: IText.body(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: IColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleWidget() {
    if (_doctor.schedule.isNotEmpty) {
      return Column(
        children: _doctor.schedule.map((day) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: IColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: IColors.line),
              boxShadow: IColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.day,
                    style: IText.body(
                        size: 13.5,
                        weight: FontWeight.w700,
                        color: IColors.ink)),
                const SizedBox(height: 8),
                if (day.slots.isEmpty)
                  Text('Chưa có khung giờ',
                      style: IText.body(size: 12.5, color: IColors.ink3))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: day.slots.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: IColors.primary500),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(t,
                            style: IText.body(
                                size: 12,
                                weight: FontWeight.w600,
                                color: IColors.primary500)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (_doctor.availableDays.isNotEmpty ||
        _doctor.availableTimeSlots.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_doctor.availableDays.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _doctor.availableDays.map((d) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: IColors.primary50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(d,
                      style: IText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: IColors.primary500)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (_doctor.availableTimeSlots.isNotEmpty) ...[
            Text('Khung giờ', style: IText.label(color: IColors.ink3)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _doctor.availableTimeSlots.map((time) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: IColors.primary500),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(time,
                      style: IText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: IColors.primary500)),
                );
              }).toList(),
            ),
          ],
        ],
      );
    }

    return Text('Lịch làm việc đang được cập nhật.',
        style: IText.body(size: 13.5, color: IColors.ink3));
  }

  // ════════════════════════════════════════════════════════════════════
  // TAB: ĐÁNH GIÁ (index 2)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildReviewTab() {
    final rating = _doctor.rating;
    final total = _doctor.totalReviews;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Rating overview
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: IColors.line),
            boxShadow: IColors.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Big number
                  Column(
                    children: [
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : '—',
                        style: const TextStyle(
                          fontFamily: IFont.interTight,
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: IColors.ink,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 16,
                            color: IColors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total > 0 ? '$total đánh giá' : 'Chưa có',
                        style: IText.label(color: IColors.ink3),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Rating bars
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final ratios = [0.72, 0.18, 0.06, 0.03, 0.01];
                        final ratio = ratios[5 - star];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Text('$star',
                                  style: IText.label(
                                      color: IColors.ink3, size: 10)),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded,
                                  size: 10, color: IColors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: IColors.line2,
                                    color: IColors.amber,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Header + write review button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nhận xét gần đây', style: IText.sectionTitle(color: IColors.ink)),
            GestureDetector(
              onTap: () => context.push(
                '/doctor/review/${_doctor.id}',
                extra: _doctor.name,
              ),
              child: Text('Xem tất cả',
                  style: IText.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: IColors.primary500)),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Sample review cards (mock data, real rating used for stars)
        _buildReviewCard(
          name: 'Nguyễn Văn An',
          date: '12/05/2025',
          stars: rating.round().clamp(4, 5),
          text:
              'Bác sĩ rất tận tâm, giải thích rõ ràng từng bước điều trị. Phòng khám sạch sẽ, nhân viên thân thiện. Sẽ quay lại lần sau!',
          initials: 'NA',
          color: IColors.primary500,
        ),
        const SizedBox(height: 10),
        _buildReviewCard(
          name: 'Trần Thị Bích Loan',
          date: '03/05/2025',
          stars: (rating.round() - 1).clamp(3, 5),
          text:
              'Thái độ bác sĩ rất chuyên nghiệp. Tuy nhiên thời gian chờ hơi lâu, khoảng 30 phút. Nhìn chung hài lòng với kết quả khám.',
          initials: 'BL',
          color: IColors.violet,
        ),

        const SizedBox(height: 16),

        // Write review button
        OutlinedButton.icon(
          onPressed: () => context.push(
            '/doctor/review/${_doctor.id}',
            extra: _doctor.name,
          ),
          icon: const Icon(Icons.star_outline_rounded, size: 18),
          label: const Text('Viết đánh giá'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: const BorderSide(color: IColors.primary500),
            foregroundColor: IColors.primary500,
            textStyle: const TextStyle(
              fontFamily: IFont.inter,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String date,
    required int stars,
    required String text,
    required String initials,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar initials
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: IFont.interTight,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: IText.body(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: IColors.ink)),
                    Text(date, style: IText.label(color: IColors.ink3)),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < stars
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 13,
                    color: IColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: IText.body(size: 13, color: IColors.ink2)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // TAB: BÀI VIẾT (index 3)
  // ════════════════════════════════════════════════════════════════════
  Widget _buildArticlesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: IColors.primary50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.article_outlined,
                  color: IColors.primary500, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Chưa có bài viết',
                style: IText.sectionTitle(color: IColors.ink)),
            const SizedBox(height: 6),
            Text('Bác sĩ chưa đăng bài viết nào.',
                style: IText.body(size: 13, color: IColors.ink3),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // STICKY BOTTOM CTA
  // ════════════════════════════════════════════════════════════════════
  Widget _buildStickyBottomCTA() {
    final hasSlot = _selectedSlot != null;
    final timeLabel = _ctaTimeLabel;

    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        border: const Border(top: BorderSide(color: IColors.line)),
        boxShadow: [
          BoxShadow(
            color: IColors.ink.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: hasSlot
              ? _buildCtaWithSlot(timeLabel!)
              : _buildCtaEmpty(),
        ),
      ),
    );
  }

  Widget _buildCtaEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: IColors.line2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Chọn giờ để tiếp tục',
        textAlign: TextAlign.center,
        style: IText.body(
            size: 14, weight: FontWeight.w600, color: IColors.ink3),
      ),
    );
  }

  Widget _buildCtaWithSlot(String timeLabel) {
    return GestureDetector(
      onTap: () => context.push(
        '/patient/create-appointment',
        extra: {'doctor': _doctor},
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [IColors.navy, IColors.primary500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: IColors.elevatedShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time & date
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontFamily: IFont.inter,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Price + BHYT badge
                  Row(
                    children: [
                      Text(
                        _servicePriceLabel,
                        style: const TextStyle(
                          fontFamily: IFont.interTight,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BHYT',
                          style: TextStyle(
                            fontFamily: IFont.inter,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow button circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared helper ────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: IText.label(color: IColors.ink3, size: 11),
      );
}

// ─── SliverPersistentHeaderDelegate for tab bar ──────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: IColors.bg,
      child: Column(
        children: [
          tabBar,
          const Divider(height: 1, color: IColors.line),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

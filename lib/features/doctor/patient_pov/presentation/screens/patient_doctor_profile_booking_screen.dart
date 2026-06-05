import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/icare_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Patient Doctor Profile + Full Booking Flow
// ═══════════════════════════════════════════════════════════════════════════

class PatientDoctorProfileBookingScreen extends StatefulWidget {
  const PatientDoctorProfileBookingScreen({super.key});

  @override
  State<PatientDoctorProfileBookingScreen> createState() =>
      _PatientDoctorProfileBookingScreenState();
}

class _PatientDoctorProfileBookingScreenState
    extends State<PatientDoctorProfileBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedService = 0;
  int _selectedDateIndex = 2;
  String? _selectedTime;
  bool _isFavorite = false;
  final _notesCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _services = [
    (
      icon: Icons.local_hospital_rounded,
      title: 'Khám trực tiếp',
      duration: '30 phút',
      price: 350000,
      note: 'Tại BV Bạch Mai · Phòng 214',
      bhyt: true,
    ),
    (
      icon: Icons.videocam_rounded,
      title: 'Khám trực tuyến',
      duration: '20 phút',
      price: 250000,
      note: 'Video call qua ICare Meet',
      bhyt: true,
    ),
    (
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Tư vấn tin nhắn',
      duration: 'Trả lời trong 4h',
      price: 120000,
      note: 'Chat 24/7, phản hồi nhanh',
      bhyt: false,
    ),
  ];

  static const _dates = [
    ('T3', 21, _Dot.many),
    ('T4', 22, _Dot.few),
    ('T5', 23, _Dot.many),
    ('T6', 24, _Dot.few),
    ('T7', 25, _Dot.none),
    ('CN', 26, _Dot.off),
  ];

  static const _morningSlots = [
    ('08:00', false), ('08:30', false), ('09:00', false), ('09:30', true),
    ('10:00', true), ('10:30', true), ('11:00', false), ('11:30', true),
  ];

  static const _afternoonSlots = [
    ('13:30', true), ('14:00', false), ('14:30', true),
    ('15:00', false), ('15:30', true), ('16:00', true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverToBoxAdapter(child: _buildHero()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBar(_tabController),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingTab(),
                      _buildAboutTab(),
                      _buildReviewsTab(),
                      _buildArticlesTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildStickyBottom()),
        ],
      ),
    );
  }

  // ─── Hero Header ──────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [IColors.primary100, IColors.bg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _iconBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.maybePop(context)),
                  const Spacer(),
                  _iconBtn(
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    () => setState(() => _isFavorite = !_isFavorite),
                    color: _isFavorite ? IColors.danger : IColors.ink,
                  ),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.ios_share_rounded, () {}),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Avatar with glow
            _buildAvatar(),
            const SizedBox(height: 14),

            // Meta
            Text('TIM MẠCH · CHUYÊN KHOA II',
                style: IText.label(size: 11, color: IColors.primary700)),
            const SizedBox(height: 6),
            Text('BS. Trần Minh Quân',
                style: IText.display(size: 22, color: IColors.ink)),
            const SizedBox(height: 4),
            Text('BV Bạch Mai · 15 năm kinh nghiệm',
                style: IText.body(size: 13, color: IColors.ink3)),
            const SizedBox(height: 12),

            // Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ratingPill(),
                const SizedBox(width: 8),
                const IPill(label: 'Đang mở slot', dot: true,
                    bg: IColors.successBg, fg: IColors.success),
              ],
            ),
            const SizedBox(height: 18),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStatsGrid(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), IColors.primary700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: IColors.primary500.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('MQ',
                style: TextStyle(
                  fontFamily: IFont.interTight,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                )),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: IColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 13),
          ),
        ),
      ],
    );
  }

  Widget _ratingPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: IColors.amberBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: IColors.amber),
          const SizedBox(width: 4),
          Text('4.9 ', style: IText.num(size: 12, color: IColors.amber, weight: FontWeight.w800)),
          Text('(312)', style: IText.label(size: 10.5, color: IColors.amber)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _stat('4.2K', 'Bệnh nhân', IColors.primary500),
            _statDiv(),
            _stat('15', 'Năm KN', IColors.mint),
            _statDiv(),
            _stat('97%', 'Hài lòng', IColors.success),
            _statDiv(),
            _stat('350K', 'Phí khám', IColors.amber),
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l, Color c) => Expanded(
    child: Column(children: [
      Text(v, style: IText.num(size: 18, weight: FontWeight.w800, color: c)),
      const SizedBox(height: 3),
      Text(l.toUpperCase(), style: IText.label(size: 9.5, color: IColors.ink3)),
    ]),
  );

  Widget _statDiv() => Container(width: 1, height: 30, color: IColors.line);

  // ─── Booking Tab ─────────────────────────────────────────────────────────────
  Widget _buildBookingTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSnippet(),
          const SizedBox(height: 22),
          _buildSectionLabel('Chọn loại dịch vụ'),
          const SizedBox(height: 10),
          ..._services.indexed.map((e) => _buildServiceCard(e.$1)),
          const SizedBox(height: 22),
          _buildSectionLabel('Chọn ngày khám'),
          const SizedBox(height: 12),
          _buildDateRow(),
          const SizedBox(height: 10),
          _buildDateLegend(),
          const SizedBox(height: 22),
          _buildSlotSection('CA SÁNG · 08:00 – 11:30', _morningSlots),
          const SizedBox(height: 16),
          _buildSlotSection('CA CHIỀU · 13:30 – 16:30', _afternoonSlots),
          const SizedBox(height: 22),
          _buildSectionLabel('Lý do khám (tuỳ chọn)'),
          const SizedBox(height: 10),
          _buildNotesBox(),
        ],
      ),
    );
  }

  Widget _buildAboutSnippet() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.primary50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.primary100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: IColors.primary100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_rounded, color: IColors.primary500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chuyên gia can thiệp mạch vành và rối loạn nhịp tim. Fellow tại St. Mary\'s London 2018. 2.400+ ca can thiệp, tỷ lệ thành công 97.8%.',
              style: IText.body(size: 12.5, color: IColors.ink2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(int i) {
    final s = _services[i];
    final sel = _selectedService == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel ? IColors.primary50 : IColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? IColors.primary500 : IColors.line,
            width: sel ? 1.5 : 1.0,
          ),
          boxShadow: sel ? IColors.cardShadow : [],
        ),
        child: Row(
          children: [
            // Radio
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? IColors.surface : Colors.transparent,
                border: Border.all(
                  color: sel ? IColors.primary500 : IColors.ink200,
                  width: sel ? 5.5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icon tile
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: sel ? IColors.primary100 : IColors.line2,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(s.icon, color: sel ? IColors.primary500 : IColors.ink3, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(s.title, style: IText.body(size: 14, weight: FontWeight.w600, color: IColors.ink)),
                    if (s.bhyt) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: IColors.successBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('BHYT', style: IText.label(size: 9, color: IColors.success)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(s.note, style: IText.body(size: 11.5, color: IColors.ink3)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${s.price ~/ 1000}K',
                    style: IText.num(size: 16, weight: FontWeight.w800, color: sel ? IColors.primary500 : IColors.ink)),
                Text(s.duration, style: IText.label(size: 10, color: IColors.ink3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = _dates[i];
          final isOff = d.$3 == _Dot.off;
          final sel = _selectedDateIndex == i && !isOff;

          return GestureDetector(
            onTap: isOff ? null : () => setState(() => _selectedDateIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              decoration: BoxDecoration(
                color: sel ? IColors.ink : isOff ? IColors.line2 : IColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? IColors.ink : IColors.line),
                boxShadow: sel ? IColors.cardShadow : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1,
                      style: IText.label(
                        size: 10.5,
                        color: sel ? Colors.white60 : isOff ? IColors.ink200 : IColors.ink3,
                      )),
                  const SizedBox(height: 5),
                  Text('${d.$2}',
                      style: IText.num(
                        size: 22,
                        weight: FontWeight.w800,
                        color: sel ? Colors.white : isOff ? IColors.ink200 : IColors.ink,
                      )),
                  const SizedBox(height: 5),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: sel
                          ? Colors.white.withValues(alpha: 0.5)
                          : isOff
                              ? IColors.ink200
                              : _dotColor(d.$3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _dotColor(_Dot d) {
    switch (d) {
      case _Dot.many: return IColors.success;
      case _Dot.few:  return IColors.warning;
      case _Dot.none: return IColors.danger;
      case _Dot.off:  return IColors.ink200;
    }
  }

  Widget _buildDateLegend() {
    return Row(
      children: [
        _legend('Còn nhiều', IColors.success),
        const SizedBox(width: 14),
        _legend('Còn ít', IColors.warning),
        const SizedBox(width: 14),
        _legend('Hết slot', IColors.danger),
        const SizedBox(width: 14),
        _legend('Nghỉ CN', IColors.ink200),
      ],
    );
  }

  Widget _legend(String t, Color c) => Row(children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(t, style: IText.label(size: 10, color: IColors.ink3)),
  ]);

  Widget _buildSlotSection(String label, List<(String, bool)> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(
            color: IColors.primary500, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label, style: IText.label(color: IColors.ink2)),
        ]),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.5,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) {
            final slot = slots[i];
            final avail = slot.$2;
            final sel = _selectedTime == slot.$1 && avail;
            return GestureDetector(
              onTap: !avail ? null : () => setState(() {
                _selectedTime = _selectedTime == slot.$1 ? null : slot.$1;
                HapticFeedback.selectionClick();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: sel ? IColors.primary500 : !avail ? IColors.line2 : IColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? IColors.primary500 : IColors.line),
                  boxShadow: sel ? [BoxShadow(color: IColors.primary500.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))] : [],
                ),
                child: Center(child: Text(
                  slot.$1,
                  style: TextStyle(
                    fontFamily: IFont.interTight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : !avail ? IColors.ink200 : IColors.ink,
                    decoration: !avail ? TextDecoration.lineThrough : null,
                    decorationColor: IColors.ink200,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                )),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesBox() {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: 4,
        style: IText.body(size: 13.5),
        decoration: InputDecoration(
          hintText: 'Mô tả triệu chứng, tiền sử bệnh hoặc câu hỏi muốn hỏi bác sĩ...',
          hintStyle: IText.body(size: 13, color: IColors.ink3).copyWith(fontStyle: FontStyle.italic),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ─── About Tab ─────────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard('Chuyên môn & Kinh nghiệm', Icons.medical_services_rounded, IColors.primary500, [
            'Chuyên gia hàng đầu về can thiệp mạch vành và điều trị rối loạn nhịp tim phức tạp.',
            'Hoàn thành Fellowship tại Bệnh viện St. Mary\'s, London năm 2018.',
            'Thực hiện thành công 2.400+ ca can thiệp với tỷ lệ thành công 97.8%.',
            'Nghiên cứu sinh tại Trường Y Harvard 2020–2021.',
          ]),
          const SizedBox(height: 14),
          _infoCard('Học vấn & Đào tạo', Icons.school_rounded, IColors.violet, [
            '• ĐH Y Hà Nội — Tiến sĩ Y khoa (2005)',
            '• BV Bạch Mai — Chuyên khoa II Tim mạch (2010)',
            '• St. Mary\'s London — Fellow Can thiệp Tim (2018)',
            '• Harvard Medical School — Research Fellow (2020)',
          ]),
          const SizedBox(height: 14),
          _buildLanguageCard(),
          const SizedBox(height: 14),
          _buildHospitalCard(),
          const SizedBox(height: 14),
          _buildAvailabilityCard(),
        ],
      ),
    );
  }

  Widget _infoCard(String title, IconData icon, Color color, List<String> items) {
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
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
          ]),
          const SizedBox(height: 12),
          const Divider(color: IColors.line, height: 1),
          const SizedBox(height: 12),
          ...items.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(t, style: IText.body(size: 13, color: IColors.ink2)),
          )),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: IColors.mintBg, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.language_rounded, color: IColors.mint, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NGÔN NGỮ', style: IText.label(color: IColors.ink3)),
            const SizedBox(height: 6),
            Row(
              children: ['Tiếng Việt', 'English'].map((lang) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: IColors.primary100),
                ),
                child: Text(lang, style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.primary500)),
              )).toList(),
            ),
          ],
        ),
      ]),
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
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [IColors.primary50, IColors.primary100],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: IColors.primary500, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bệnh viện Bạch Mai', style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
                Text('78 Giải Phóng, Đống Đa, Hà Nội', style: IText.body(size: 12, color: IColors.ink3)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: IColors.successBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('1.2km', style: IText.label(size: 10, color: IColors.success)),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(color: IColors.line, height: 1),
          const SizedBox(height: 12),
          _hospitalRow(Icons.access_time_rounded, 'T2–T6: 07:30–11:30, 13:30–16:30', IColors.ink3),
          const SizedBox(height: 6),
          _hospitalRow(Icons.shield_rounded, 'Nhận BHYT Giá đỡ 1–5', IColors.success),
          const SizedBox(height: 6),
          _hospitalRow(Icons.directions_car_rounded, 'Đi xe ~6 phút từ Cầu Giấy', IColors.ink3),
        ],
      ),
    );
  }

  Widget _hospitalRow(IconData icon, String text, Color color) => Row(children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 8),
    Text(text, style: IText.body(size: 12.5, color: color == IColors.ink3 ? IColors.ink2 : color, weight: FontWeight.w500)),
  ]);

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IColors.primary50, IColors.surface],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.primary100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: IColors.primary500),
            const SizedBox(width: 8),
            Text('Lịch khám tuần này', style: IText.body(size: 13.5, weight: FontWeight.w700, color: IColors.ink)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              _dayAvail('T3', '3'),
              _dayAvail('T4', '2'),
              _dayAvail('T5', '5'),
              _dayAvail('T6', '2'),
              _dayAvail('T7', '0', off: true),
              _dayAvail('CN', '0', off: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayAvail(String day, String count, {bool off = false}) {
    return Expanded(
      child: Column(children: [
        Text(day, style: IText.label(size: 10, color: off ? IColors.ink200 : IColors.ink3)),
        const SizedBox(height: 4),
        Container(
          height: 28,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: off ? IColors.line2 : count == '0' ? IColors.dangerBg : IColors.successBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              off ? '–' : count,
              style: IText.num(
                size: 12,
                weight: FontWeight.w800,
                color: off ? IColors.ink200 : count == '0' ? IColors.danger : IColors.success,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Reviews Tab ─────────────────────────────────────────────────────────────
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        children: [
          _buildRatingOverviewCard(),
          const SizedBox(height: 14),
          _buildReviewTagsCard(),
          const SizedBox(height: 14),
          ..._buildReviewItems(),
        ],
      ),
    );
  }

  Widget _buildRatingOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(
        children: [
          Column(children: [
            Text('4.9', style: IText.num(size: 52, weight: FontWeight.w800, color: IColors.ink)),
            Row(children: List.generate(5, (i) => Icon(
              i < 5 ? Icons.star_rounded : Icons.star_border_rounded,
              color: IColors.amber, size: 16,
            ))),
            const SizedBox(height: 4),
            Text('312 đánh giá', style: IText.label(size: 10.5, color: IColors.ink3)),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(
            children: [
              _ratingBar(5, 0.82, 256),
              _ratingBar(4, 0.12, 37),
              _ratingBar(3, 0.04, 13),
              _ratingBar(2, 0.01, 3),
              _ratingBar(1, 0.01, 3),
            ],
          )),
        ],
      ),
    );
  }

  Widget _ratingBar(int star, double ratio, int count) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Text('$star', style: IText.label(size: 10, color: IColors.ink3)),
      const SizedBox(width: 3),
      const Icon(Icons.star_rounded, size: 10, color: IColors.amber),
      const SizedBox(width: 6),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: ratio,
          backgroundColor: IColors.line2,
          valueColor: const AlwaysStoppedAnimation(IColors.amber),
          minHeight: 7,
        ),
      )),
      const SizedBox(width: 6),
      SizedBox(
        width: 22,
        child: Text('$count', style: IText.label(size: 10, color: IColors.ink3), textAlign: TextAlign.right),
      ),
    ]),
  );

  Widget _buildReviewTagsCard() {
    final tags = [
      ('Tận tâm', 186), ('Chẩn đoán chuẩn', 142), ('Giải thích kỹ', 129),
      ('Đúng giờ', 98), ('Sạch sẽ', 76), ('Giá hợp lý', 61),
    ];
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
          Text('Điểm nổi bật', style: IText.body(size: 13.5, weight: FontWeight.w700, color: IColors.ink)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: IColors.primary50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: IColors.primary100),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t.$1, style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.primary500)),
                const SizedBox(width: 5),
                Text('${t.$2}', style: IText.num(size: 11, color: IColors.primary700)),
              ]),
            )).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReviewItems() {
    final items = [
      ('Nguyễn Văn An', '23/05/2026', 5,
          'BS. Quân rất tận tâm và chuyên nghiệp. Giải thích rất kỹ về tình trạng bệnh, không vội vàng. Phòng khám sạch sẽ, không phải chờ lâu.',
          ['Tận tâm', 'Đúng giờ']),
      ('Trần Thị Bình', '18/05/2026', 5,
          'Chẩn đoán chính xác, điều trị hiệu quả. Tôi đã đi khám nhiều nơi nhưng bác sĩ Quân thực sự rất giỏi và tận tình.',
          ['Chẩn đoán chuẩn', 'Giải thích kỹ']),
      ('Lê Minh Châu', '10/05/2026', 4,
          'Bác sĩ có kinh nghiệm, tư vấn rất cặn kẽ. Chỉ có điều đặt lịch hơi khó do slot hay đầy sớm.',
          ['Tận tâm']),
    ];
    return items.map((r) => Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          Row(children: [
            _initAvatar(r.$1[0], IColors.primary500),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.$1, style: IText.body(size: 13.5, weight: FontWeight.w600, color: IColors.ink)),
              Text(r.$2, style: IText.label(size: 10.5, color: IColors.ink3)),
            ])),
            Row(children: List.generate(5, (i) => Icon(
              i < r.$3 ? Icons.star_rounded : Icons.star_border_rounded,
              color: IColors.amber, size: 14,
            ))),
          ]),
          const SizedBox(height: 10),
          Text(r.$4, style: IText.body(size: 13, color: IColors.ink2)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: r.$5.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: IColors.successBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(t, style: IText.label(size: 10, color: IColors.success)),
          )).toList()),
        ],
      ),
    )).toList();
  }

  // ─── Articles Tab ─────────────────────────────────────────────────────────────
  Widget _buildArticlesTab() {
    final items = [
      ('5 dấu hiệu cảnh báo bệnh tim mạch nên đi khám ngay', '23/05/2026', '5 phút', '12.4K', const [Color(0xFFFF6B35), IColors.rose]),
      ('Tăng huyết áp và những điều cần biết trước 40 tuổi', '10/05/2026', '4 phút', '8.2K', const [Color(0xFF5B47D6), IColors.violet]),
      ('Phân biệt đau thắt ngực và nhồi máu cơ tim', '02/05/2026', '6 phút', '15.1K', const [IColors.primary500, IColors.primary700]),
    ];
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(children: items.map((a) => _articleCard(a)).toList()),
    );
  }

  Widget _articleCard(dynamic a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: IColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: IColors.line),
      boxShadow: IColors.cardShadow,
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 76, height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: a.$5 as List<Color>,
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: const Center(child: Icon(Icons.favorite_rounded, color: Colors.white, size: 30)),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const IPill(label: 'TIM MẠCH', bg: IColors.roseBg, fg: IColors.rose),
        const SizedBox(height: 6),
        Text(a.$1 as String, style: IText.body(size: 13.5, weight: FontWeight.w600, color: IColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          Text(a.$2 as String, style: IText.label(size: 10.5, color: IColors.ink3)),
          Container(margin: const EdgeInsets.symmetric(horizontal: 6), width: 3, height: 3, decoration: const BoxDecoration(color: IColors.ink200, shape: BoxShape.circle)),
          Text('${a.$3} đọc', style: IText.label(size: 10.5, color: IColors.ink3)),
          Container(margin: const EdgeInsets.symmetric(horizontal: 6), width: 3, height: 3, decoration: const BoxDecoration(color: IColors.ink200, shape: BoxShape.circle)),
          Text('${a.$4} lượt', style: IText.label(size: 10.5, color: IColors.ink3)),
        ]),
      ])),
    ]),
  );

  // ─── Sticky Bottom CTA ───────────────────────────────────────────────────────
  Widget _buildStickyBottom() {
    final s = _services[_selectedService];
    final d = _dates[_selectedDateIndex];
    final canBook = _selectedTime != null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IColors.primary500, IColors.primary700],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        boxShadow: [BoxShadow(
          color: IColors.primary500.withValues(alpha: 0.45),
          blurRadius: 30, offset: const Offset(0, -10),
        )],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  canBook
                      ? '${d.$1}, ${d.$2}/05 · $_selectedTime · ${s.title}'
                      : 'Chọn ngày & giờ để đặt khám',
                  style: IText.label(size: 11, color: Colors.white.withValues(alpha: 0.8)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    '${s.price ~/ 1000}.000đ',
                    style: IText.num(size: 20, weight: FontWeight.w800, color: Colors.white),
                  ),
                  if (s.bhyt) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text('BHYT −80%', style: IText.label(size: 10, color: Colors.white)),
                    ),
                  ],
                ]),
              ],
            )),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: canBook ? () {
                HapticFeedback.mediumImpact();
                context.push('/booking/confirmation');
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: canBook ? Colors.white : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  boxShadow: canBook ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 6))] : [],
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: canBook ? IColors.primary500 : Colors.white.withValues(alpha: 0.5), size: 24),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, VoidCallback? onTap, {Color color = IColors.ink}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: IColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildSectionLabel(String t) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(
      color: IColors.primary500, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(t.toUpperCase(), style: IText.label(color: IColors.ink2)),
  ]);

  Widget _initAvatar(String init, Color color) => Container(
    width: 38, height: 38,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(init, style: TextStyle(
      fontFamily: IFont.interTight, fontSize: 15,
      fontWeight: FontWeight.w800, color: color,
    ))),
  );
}

enum _Dot { many, few, none, off }

// ─── Sticky Tab Bar ───────────────────────────────────────────────────────────
class _StickyTabBar extends SliverPersistentHeaderDelegate {
  final TabController controller;
  const _StickyTabBar(this.controller);

  @override double get minExtent => 48;
  @override double get maxExtent => 48;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IColors.bg,
        border: Border(bottom: BorderSide(color: IColors.line)),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: const TextStyle(
          fontFamily: IFont.inter, fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: IFont.inter, fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        labelColor: IColors.ink,
        unselectedLabelColor: IColors.ink3,
        indicatorColor: IColors.ink,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        tabs: const [
          Tab(text: 'Đặt lịch'),
          Tab(text: 'Giới thiệu'),
          Tab(text: 'Đánh giá 312'),
          Tab(text: 'Bài viết 8'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBar old) => old.controller != controller;
}

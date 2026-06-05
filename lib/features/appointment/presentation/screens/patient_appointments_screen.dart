import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/icare_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Patient → Lịch hẹn của tôi — Full Appointments Screen
// ═══════════════════════════════════════════════════════════════════════════

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildGreetingBlock(),
            _buildMiniStats(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingTab(),
                  _buildCompletedTab(),
                  _buildCancelledTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: IColors.surface, shape: BoxShape.circle,
                border: Border.all(color: IColors.line),
                boxShadow: IColors.cardShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: IColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Text('Lịch hẹn', style: IText.display(size: 22, color: IColors.ink)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/doctor/search'),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: IColors.surface, borderRadius: BorderRadius.circular(11),
                border: Border.all(color: IColors.line),
                boxShadow: IColors.cardShadow,
              ),
              child: const Icon(Icons.search_rounded, size: 20, color: IColors.ink),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/patient/create-appointment'),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [IColors.primary500, IColors.primary700],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(color: IColors.primary500.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Greeting Block ─────────────────────────────────────────────────────────
  Widget _buildGreetingBlock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [IColors.navy, IColors.navyMid, IColors.primary500],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: IColors.primary500.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 20),
                ),
              ),
            ),
            Positioned(
              right: 20, bottom: -30,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 16),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SẮP TỚI TRONG TUẦN NÀY', style: IText.label(size: 10, color: Colors.white54)),
                const SizedBox(height: 8),
                Text('3 lịch khám', style: IText.display(size: 26, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Gần nhất: BS. Quân · ngày mai 09:30. Mã QR đã sẵn sàng.',
                    style: IText.body(size: 12.5, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mini Stats ──────────────────────────────────────────────────────────────
  Widget _buildMiniStats() {
    final stats = [
      (label: 'Tổng năm nay', value: '12', icon: Icons.calendar_today_rounded, color: IColors.primary500, bg: IColors.primary50),
      (label: 'Bác sĩ', value: '8', icon: Icons.people_alt_rounded, color: IColors.mint, bg: IColors.mintBg),
      (label: 'TB đánh giá', value: '4.8★', icon: Icons.star_rounded, color: IColors.amber, bg: IColors.amberBg),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: stats.indexed.map((e) {
          final s = e.$2;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: e.$1 < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: IColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: IColors.line),
                boxShadow: IColors.cardShadow,
              ),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(s.icon, size: 14, color: s.color),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.value, style: IText.num(size: 13, weight: FontWeight.w800, color: s.color)),
                  Text(s.label, style: IText.label(size: 9, color: IColors.ink3)),
                ])),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Tab Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: IColors.line2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: IColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: IColors.cardShadow,
          ),
          labelStyle: const TextStyle(fontFamily: IFont.inter, fontSize: 12.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontFamily: IFont.inter, fontSize: 12.5, fontWeight: FontWeight.w500),
          labelColor: IColors.ink,
          unselectedLabelColor: IColors.ink3,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: 'Sắp tới  3'),
            Tab(text: 'Hoàn thành  12'),
            Tab(text: 'Đã hủy  1'),
          ],
        ),
      ),
    );
  }

  // ─── Upcoming Tab ────────────────────────────────────────────────────────────
  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      children: [
        // Primary (upcoming, confirmed)
        _buildPrimaryAppointmentCard(),
        const SizedBox(height: 10),
        // Online pending
        _buildOnlineAppointmentCard(),
        const SizedBox(height: 10),
        // Future in-person
        _buildFutureAppointmentCard(),
        const SizedBox(height: 14),
        // Reminder card
        _buildReminderCard(),
      ],
    );
  }

  Widget _buildPrimaryAppointmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.elevatedShadow,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Date gradient stripe
              Container(
                height: 84,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [IColors.navy, IColors.navyMid],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative pattern
                    Positioned(
                      right: -10, top: -10,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Date block
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(children: [
                              Text('T5', style: IText.label(size: 10, color: Colors.white60)),
                              Text('23', style: IText.num(size: 24, weight: FontWeight.w800, color: Colors.white)),
                              Text('TH 05', style: IText.label(size: 9.5, color: Colors.white60)),
                            ]),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('LỊCH KHÁM SẮP TỚI', style: IText.label(size: 9.5, color: Colors.white60)),
                              const SizedBox(height: 6),
                              Text('BS. Trần Minh Quân', style: IText.body(size: 15, weight: FontWeight.w700, color: Colors.white)),
                              Text('Tim mạch · 30 phút', style: IText.body(size: 12, color: Colors.white.withValues(alpha: 0.7))),
                            ],
                          ),
                          const Spacer(),
                          // Time pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('09:30', style: IText.num(size: 14, weight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Location row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: IColors.line2, borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        const Icon(Icons.location_on_rounded, size: 15, color: IColors.primary500),
                        const SizedBox(width: 7),
                        Expanded(child: Text('BV Bạch Mai · Phòng 214 · Tầng 2', style: IText.body(size: 12.5, color: IColors.ink2))),
                      ]),
                    ),
                    const SizedBox(height: 10),

                    // Pills row
                    Row(children: [
                      const IPill(label: 'Đã xác nhận', bg: IColors.successBg, fg: IColors.success, dot: true),
                      const SizedBox(width: 8),
                      const IPill(label: 'BHYT', bg: IColors.primary50, fg: IColors.primary500),
                      const Spacer(),
                      Text('350.000đ', style: IText.num(size: 14, weight: FontWeight.w700, color: IColors.ink)),
                    ]),
                    const SizedBox(height: 10),

                    // Divider
                    const Divider(color: IColors.line, height: 1),
                    const SizedBox(height: 10),

                    // Footer dark
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: IColors.ink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        // STT chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('STT A·07', style: IText.num(size: 12, weight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('~ 18 phút chờ', style: IText.body(size: 12, color: Colors.white.withValues(alpha: 0.7))),
                        ),
                        // QR icon
                        GestureDetector(
                          onTap: () => context.push('/clinic/scanner', extra: {'appointmentId': 'apt_001'}),
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Navigate CTA
                        GestureDetector(
                          onTap: () => context.push('/maps'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [IColors.primary500, IColors.primary700],
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text('Chỉ đường →', style: IText.body(size: 12, weight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Countdown ribbon
          Positioned(
            right: 14, top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: IColors.primary500.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [BoxShadow(color: IColors.primary500.withValues(alpha: 0.4), blurRadius: 10)],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.timer_rounded, size: 11, color: Colors.white),
                const SizedBox(width: 4),
                Text('17h 32m', style: IText.num(size: 11, weight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(children: [
            // Small date block
            Container(
              width: 52, height: 62,
              decoration: BoxDecoration(
                color: IColors.line2, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: IColors.line),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('T4', style: IText.label(size: 10, color: IColors.ink3)),
                Text('28', style: IText.num(size: 20, weight: FontWeight.w800, color: IColors.ink)),
                Text('TH05', style: IText.label(size: 9.5, color: IColors.ink3)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B47D6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam_rounded, color: IColors.violet, size: 16),
                ),
                const SizedBox(width: 8),
                Text('10:00', style: IText.num(size: 15, weight: FontWeight.w700, color: IColors.ink)),
                const SizedBox(width: 8),
                const IPill.violet('VIDEO'),
              ]),
              const SizedBox(height: 6),
              Text('BS. Nguyễn Lan Anh', style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
              Text('Nội khoa · 20 phút', style: IText.body(size: 12, color: IColors.ink3)),
            ])),
          ]),
          const SizedBox(height: 12),
          const Divider(color: IColors.line, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            const IPill(label: 'Chờ xác nhận', bg: IColors.warningBg, fg: IColors.warning, dot: true),
            const Spacer(),
            Text('Đặt hôm nay 09:24', style: IText.label(size: 11, color: IColors.ink3)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/appointments'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: IColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: IColors.line),
                  ),
                  child: Center(child: Text('Đổi lịch', style: IText.body(size: 13, weight: FontWeight.w600, color: IColors.ink))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/appointments'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: IColors.primary50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: IColors.primary100),
                  ),
                  child: Center(child: Text('Chi tiết', style: IText.body(size: 13, weight: FontWeight.w600, color: IColors.primary500))),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFutureAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 52, height: 62,
          decoration: BoxDecoration(
            color: IColors.line2, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: IColors.line),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('T6', style: IText.label(size: 10, color: IColors.ink3)),
            Text('30', style: IText.num(size: 20, weight: FontWeight.w800, color: IColors.ink)),
            Text('TH05', style: IText.label(size: 9.5, color: IColors.ink3)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('14:00', style: IText.num(size: 15, weight: FontWeight.w700, color: IColors.ink)),
          const SizedBox(height: 4),
          Text('BS. Phạm Thị Hạnh', style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
          Text('Da liễu · 30 phút · BV Da liễu TƯ', style: IText.body(size: 12, color: IColors.ink3)),
          const SizedBox(height: 8),
          Row(children: [
            const IPill(label: 'Đã xác nhận', bg: IColors.successBg, fg: IColors.success, dot: true),
            const SizedBox(width: 8),
            const IPill(label: 'BHYT', bg: IColors.primary50, fg: IColors.primary500),
          ]),
        ])),
        const Icon(Icons.chevron_right_rounded, color: IColors.ink3, size: 22),
      ]),
    );
  }

  // ─── Reminder Card ─────────────────────────────────────────────────────────
  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: IColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.notifications_active_rounded, color: IColors.warning, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nhắc nhở trước khi đến khám', style: IText.body(size: 13.5, weight: FontWeight.w700, color: IColors.ink)),
          const SizedBox(height: 6),
          _reminderRow('Mang theo CCCD và thẻ BHYT bản gốc'),
          _reminderRow('Nhịn ăn 8 tiếng nếu có xét nghiệm máu'),
          _reminderRow('Đến trước giờ hẹn ít nhất 15 phút'),
        ])),
      ]),
    );
  }

  Widget _reminderRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(margin: const EdgeInsets.only(top: 5), width: 5, height: 5,
          decoration: const BoxDecoration(color: IColors.warning, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: IText.body(size: 12.5, color: IColors.ink2))),
    ]),
  );

  // ─── Completed Tab ─────────────────────────────────────────────────────────
  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
      children: List.generate(4, (i) => _buildCompletedCard(i)),
    );
  }

  Widget _buildCompletedCard(int i) {
    final items = [
      ('BS. Trần Minh Quân', 'Tim mạch', '23/05/2026 · 09:30', 4.9, '350K'),
      ('BS. Nguyễn Lan Anh', 'Nội khoa', '15/05/2026 · 14:00', 5.0, '250K'),
      ('BS. Phạm Thị Hạnh', 'Da liễu', '02/05/2026 · 10:00', 4.7, '200K'),
      ('BS. Lê Văn Đức', 'Tim mạch', '20/04/2026 · 09:00', 5.0, '450K'),
    ];
    final item = items[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: IColors.successBg, borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded, color: IColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.$1, style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
            Text('${item.$2} · ${item.$3}', style: IText.body(size: 12, color: IColors.ink3)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.$5, style: IText.num(size: 13, weight: FontWeight.w700, color: IColors.ink)),
            Row(children: [
              const Icon(Icons.star_rounded, size: 11, color: IColors.amber),
              Text(' ${item.$4}', style: IText.num(size: 11, color: IColors.amber)),
            ]),
          ]),
        ]),
        const SizedBox(height: 10),
        const Divider(color: IColors.line, height: 1),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/medical-records'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: IColors.line2, borderRadius: BorderRadius.circular(9),
                ),
                child: Center(child: Text('Xem hồ sơ', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.ink))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/patient/create-appointment'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: IColors.primary50, borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: IColors.primary100),
                ),
                child: Center(child: Text('Đặt lại', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.primary500))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── Cancelled Tab ─────────────────────────────────────────────────────────
  Widget _buildCancelledTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: IColors.line),
            boxShadow: IColors.cardShadow,
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: IColors.dangerBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.cancel_rounded, color: IColors.danger, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BS. Vũ Thành Nam', style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
              Text('Thần kinh · 10/05/2026 · 09:00', style: IText.body(size: 12, color: IColors.ink3)),
              const SizedBox(height: 6),
              Text('Lý do: Bệnh nhân hủy', style: IText.label(size: 10.5, color: IColors.danger)),
            ])),
            GestureDetector(
              onTap: () => context.push('/doctor/search'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: IColors.primary50, borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: IColors.primary100),
                ),
                child: Text('Đặt lại', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.primary500)),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

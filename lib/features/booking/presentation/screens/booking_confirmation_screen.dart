import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/icare_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Patient → Xác nhận đặt khám + QR Code Screen
// ═══════════════════════════════════════════════════════════════════════════

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiCtrl;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  final List<bool> _checklistItems = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 200), () => _scaleCtrl.forward());
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _scaleCtrl.dispose();
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                children: [
                  _buildSuccessSplash(),
                  const SizedBox(height: 20),
                  _buildTicketCard(),
                  const SizedBox(height: 14),
                  _buildQuickInfoRow(),
                  const SizedBox(height: 14),
                  _buildFeeSummary(),
                  const SizedBox(height: 14),
                  _buildChecklist(),
                  const SizedBox(height: 14),
                  _buildActionButtons(),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: IColors.surface, shape: BoxShape.circle, border: Border.all(color: IColors.line), boxShadow: IColors.cardShadow),
              child: const Icon(Icons.close_rounded, size: 18, color: IColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BƯỚC 4/4 · HOÀN TẤT', style: IText.label(size: 10, color: IColors.primary500)),
              _buildStepIndicator(),
            ]),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'Lịch khám đã được xác nhận tại Smart Clinic'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép thông tin lịch hẹn')),
              );
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: IColors.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: IColors.line), boxShadow: IColors.cardShadow),
              child: const Icon(Icons.share_rounded, size: 18, color: IColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(children: List.generate(4, (i) => Expanded(
      child: Container(
        margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
        height: 3,
        decoration: BoxDecoration(
          color: IColors.primary500,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    )));
  }

  // ─── Success Splash ─────────────────────────────────────────────────────────
  Widget _buildSuccessSplash() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Confetti + check icon
          SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Confetti pieces
                ...List.generate(8, (i) => _buildConfettiPiece(i)),

                // Triple-ring success icon
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: IColors.success.withValues(alpha: 0.06),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: IColors.success.withValues(alpha: 0.1),
                        ),
                      ),
                      // Inner circle with check
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: IColors.success,
                          boxShadow: [
                            BoxShadow(color: IColors.success.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Đã đặt lịch khám!', style: IText.display(size: 26, color: IColors.ink)),
          const SizedBox(height: 8),
          Text(
            'Mã QR đã gửi qua SMS + Email.\nĐến trước giờ hẹn ít nhất 15 phút.',
            style: IText.body(size: 13, color: IColors.ink3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiPiece(int index) {
    final colors = [IColors.primary500, IColors.success, IColors.warning, IColors.violet,
                    IColors.rose, IColors.mint, IColors.amber, const Color(0xFF0056D2)];
    final angle = (index / 8) * 2 * math.pi;
    final radius = 58.0;

    return AnimatedBuilder(
      animation: _confettiCtrl,
      builder: (_, __) {
        final t = _confettiCtrl.value;
        final offset = Offset(
          radius * math.cos(angle + t * 2 * math.pi * 0.3),
          radius * math.sin(angle + t * 2 * math.pi * 0.3),
        );
        final rotation = t * 2 * math.pi * (index.isEven ? 1 : -1);

        return Positioned(
          left: 80 + offset.dx - 5,
          top: 80 + offset.dy - 5,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: index % 3 == 0 ? 10 : 7,
              height: index % 3 == 0 ? 7 : 10,
              decoration: BoxDecoration(
                color: colors[index].withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Ticket Card ─────────────────────────────────────────────────────────────
  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.elevatedShadow,
      ),
      child: Column(
        children: [
          // Brand stripe
          Container(
            height: 72,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [IColors.navy, IColors.navyMid, IColors.primary500],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                // Logo
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('ICARE · PHIẾU KHÁM', style: IText.label(size: 10.5, color: Colors.white70)),
                  Text('#APT-A7F2-09', style: IText.mono(size: 14, color: Colors.white)),
                ]),
                const Spacer(),
                const Icon(Icons.qr_code_2_rounded, color: Colors.white30, size: 32),
              ]),
            ),
          ),

          // Doctor row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(children: [
              // Avatar
              Stack(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF1976D2), IColors.primary700]),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(child: Text('MQ', style: TextStyle(
                    fontFamily: IFont.interTight, fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                  ))),
                ),
                Positioned(right: -1, bottom: -1, child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: IColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                  child: const Icon(Icons.check, color: Colors.white, size: 9),
                )),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('BÁC SĨ KHÁM · CK II', style: IText.label(size: 9.5, color: IColors.ink3)),
                const SizedBox(height: 3),
                Text('BS. Trần Minh Quân', style: IText.body(size: 14.5, weight: FontWeight.w700, color: IColors.ink)),
              ])),
              const IPill(label: 'Đã xác nhận', bg: IColors.successBg, fg: IColors.success, dot: true),
            ]),
          ),

          // Perforated divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Stack(children: [
              Row(children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: IColors.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: IColors.line),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(builder: (ctx, constraints) {
                    final n = (constraints.maxWidth / 8).floor();
                    return Row(
                      children: List.generate(n, (_) => Expanded(
                        child: Container(height: 1, color: _ % 2 == 0 ? IColors.line : Colors.transparent),
                      )),
                    );
                  }),
                ),
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: IColors.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: IColors.line),
                  ),
                ),
              ]),
            ]),
          ),

          // 4 detail tiles
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(children: [
              Row(children: [
                Expanded(child: _detailTile(Icons.calendar_today_rounded, IColors.primary500, IColors.primary50, 'NGÀY', 'T5, 23/05', '2026')),
                const SizedBox(width: 10),
                Expanded(child: _detailTile(Icons.access_time_rounded, IColors.mint, IColors.mintBg, 'GIỜ', '09:30', '30 phút')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _detailTile(Icons.location_on_rounded, IColors.violet, IColors.violetBg, 'PHÒNG', 'P.214', 'Tầng 2 · Khoa Tim')),
                const SizedBox(width: 10),
                Expanded(child: _detailTile(Icons.people_alt_rounded, IColors.amber, IColors.amberBg, 'STT', 'A·07', 'Hàng chờ')),
              ]),
            ]),
          ),

          // QR Section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: IColors.line2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: [
                // QR code placeholder
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildQRCode(),
                    // Logo overlay
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: IColors.primary500,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('#APT-A7F2-09', style: IText.mono(size: 15, color: IColors.ink)),
                const SizedBox(height: 4),
                Text('Mã hết hạn sau khi khám xong', style: IText.label(size: 10.5, color: IColors.ink3)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, Color color, Color bg, String label, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IColors.line2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: IText.label(size: 9.5, color: IColors.ink3)),
          const SizedBox(height: 2),
          Text(value, style: IText.num(size: 13, weight: FontWeight.w800, color: IColors.ink)),
          Text(sub, style: IText.body(size: 11, color: IColors.ink3)),
        ])),
      ]),
    );
  }

  Widget _buildQRCode() {
    return Container(
      width: 150, height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: IColors.cardShadow,
      ),
      child: CustomPaint(painter: _QRPatternPainter()),
    );
  }

  // ─── Quick Info Row ────────────────────────────────────────────────────────
  Widget _buildQuickInfoRow() {
    return Row(children: [
      Expanded(child: _infoCard(
        Icons.notifications_active_rounded, IColors.primary500, IColors.primary50,
        'Nhắc tự động', '15 phút trước',
      )),
      const SizedBox(width: 10),
      Expanded(child: _infoCard(
        Icons.location_on_rounded, IColors.mint, IColors.mintBg,
        'Cách 1.2km', 'Đi xe ~6 phút',
      )),
    ]);
  }

  Widget _infoCard(IconData icon, Color color, Color bg, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: IText.body(size: 12.5, weight: FontWeight.w700, color: IColors.ink)),
          Text(sub, style: IText.body(size: 11, color: IColors.ink3)),
        ])),
      ]),
    );
  }

  // ─── Fee Summary ─────────────────────────────────────────────────────────────
  Widget _buildFeeSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(children: [
        Text('TỔNG ĐÃ THANH TOÁN', style: IText.label(color: IColors.ink3)),
        const SizedBox(height: 10),
        Text('70.000đ', style: IText.num(size: 32, weight: FontWeight.w800, color: IColors.success)),
        const SizedBox(height: 6),
        Text('Gốc 350K · BHYT giảm 280K · qua VNPay', style: IText.body(size: 12, color: IColors.ink3)),
        const SizedBox(height: 12),
        const Divider(color: IColors.line, height: 1),
        const SizedBox(height: 12),
        _feeRow('Phí khám', '350.000đ', IColors.ink2),
        const SizedBox(height: 6),
        _feeRow('BHYT chi trả (80%)', '−280.000đ', IColors.success),
        const SizedBox(height: 6),
        Container(height: 1, color: IColors.line),
        const SizedBox(height: 8),
        _feeRow('Bạn thanh toán', '70.000đ', IColors.ink, isBold: true),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: IColors.successBg, borderRadius: BorderRadius.circular(999),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_rounded, size: 13, color: IColors.success),
            const SizedBox(width: 6),
            Text('Đã thanh toán qua VNPay', style: IText.body(size: 12, weight: FontWeight.w600, color: IColors.success)),
          ]),
        ),
      ]),
    );
  }

  Widget _feeRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(children: [
      Text(label, style: IText.body(size: 13, color: IColors.ink2, weight: isBold ? FontWeight.w700 : FontWeight.w400)),
      const Spacer(),
      Text(value, style: IText.num(size: 13, color: color, weight: isBold ? FontWeight.w800 : FontWeight.w600)),
    ]);
  }

  // ─── Checklist ───────────────────────────────────────────────────────────────
  Widget _buildChecklist() {
    final items = [
      'CCCD bản gốc',
      'Thẻ BHYT GD4-0123456789',
      'Đơn thuốc / hồ sơ cũ (nếu có)',
      'Nhịn ăn 8 tiếng nếu xét nghiệm máu',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.checklist_rounded, color: IColors.warning, size: 20),
          const SizedBox(width: 8),
          Text('Đừng quên mang theo', style: IText.body(size: 14, weight: FontWeight.w700, color: IColors.ink)),
        ]),
        const SizedBox(height: 12),
        ...items.indexed.map((e) => GestureDetector(
          onTap: () => setState(() { _checklistItems[e.$1] = !_checklistItems[e.$1]; HapticFeedback.selectionClick(); }),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _checklistItems[e.$1] ? IColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _checklistItems[e.$1] ? IColors.success : IColors.warning,
                    width: 1.5,
                  ),
                ),
                child: _checklistItems[e.$1]
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                e.$2,
                style: TextStyle(
                  fontFamily: IFont.inter,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _checklistItems[e.$1] ? IColors.ink3 : IColors.ink2,
                  decoration: _checklistItems[e.$1] ? TextDecoration.lineThrough : null,
                  decorationColor: IColors.ink3,
                ),
              )),
            ]),
          ),
        )),
      ]),
    );
  }

  // ─── Action Buttons ──────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(child: _actionBtn(
        icon: Icons.share_rounded,
        label: 'Chia sẻ',
        color: IColors.ink,
        bg: IColors.surface,
        border: IColors.line,
        onTap: () {
          Clipboard.setData(const ClipboardData(text: 'Tôi vừa đặt lịch khám thành công tại Smart Clinic!'));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã sao chép vào bộ nhớ tạm')),
          );
        },
      )),
      const SizedBox(width: 8),
      Expanded(child: _actionBtn(
        icon: Icons.calendar_month_rounded,
        label: 'Thêm lịch',
        color: IColors.ink,
        bg: IColors.surface,
        border: IColors.line,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch hẹn đã được lưu vào mục Lịch hẹn của bạn')),
        ),
      )),
      const SizedBox(width: 8),
      Expanded(child: _actionBtn(
        icon: Icons.directions_rounded,
        label: 'Chỉ đường',
        color: Colors.white,
        bg: IColors.primary500,
        border: Colors.transparent,
        onTap: () => GoRouter.of(context).push('/maps'),
        gradient: const LinearGradient(colors: [IColors.primary500, IColors.primary700]),
      )),
    ]);
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
    Gradient? gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: gradient != null
              ? [BoxShadow(color: IColors.primary500.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
              : IColors.cardShadow,
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: IText.body(size: 12, weight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

// ─── QR Pattern Painter ───────────────────────────────────────────────────────
class _QRPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = IColors.ink.withValues(alpha: 0.85);
    const cell = 7.0;
    const margin = 14.0;
    final cols = ((size.width - margin * 2) / cell).floor();
    final rows = ((size.height - margin * 2) / cell).floor();

    final r = math.Random(42);

    // Finder patterns (corner squares)
    _drawFinder(canvas, paint, margin, margin, cell);
    _drawFinder(canvas, paint, size.width - margin - cell * 7, margin, cell);
    _drawFinder(canvas, paint, margin, size.height - margin - cell * 7, cell);

    // Data cells
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = margin + col * cell;
        final y = margin + row * cell;

        // Skip finder pattern areas
        final inTopLeft    = row < 8 && col < 8;
        final inTopRight   = row < 8 && col > cols - 9;
        final inBottomLeft = row > rows - 9 && col < 8;

        if (inTopLeft || inTopRight || inBottomLeft) continue;

        if (r.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 0.5, y + 0.5, cell - 1, cell - 1),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, Paint paint, double x, double y, double cell) {
    // Outer square 7x7
    final outer = Paint()..color = IColors.ink..style = PaintingStyle.stroke..strokeWidth = cell;
    canvas.drawRect(Rect.fromLTWH(x + cell / 2, y + cell / 2, cell * 6, cell * 6), outer);
    // White gap
    final gap = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5), gap);
    // Inner black 3x3
    final inner = Paint()..color = IColors.ink;
    canvas.drawRect(Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3), inner);
  }

  @override
  bool shouldRepaint(covariant _QRPatternPainter old) => false;
}

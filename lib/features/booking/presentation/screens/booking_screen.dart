import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import "package:smart_clinic_booking/shared/di/injection.dart";
import '../../../../core/theme/icare_tokens.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../doctor/patient_pov/domain/entities/doctor_entity.dart';
import '../../../doctor/patient_pov/presentation/screens/doctor_search_screen.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/check_slot_availability_usecase.dart';
import '../../domain/usecases/confirm_booking_usecase.dart';
import '../../domain/usecases/expire_stale_unpaid_bookings_usecase.dart';
import '../../domain/usecases/join_waitlist_usecase.dart';
import '../../domain/usecases/lock_slot_usecase.dart';
import '../../domain/usecases/release_slot_lock_usecase.dart';
import '../../domain/usecases/reschedule_booking_usecase.dart';
import '../controllers/booking_controller.dart';
import 'package:smart_clinic_booking/features/checkin/presentation/screens/appointment_qr_screen.dart';

/// Đặt lịch khám — Firestore `bookings` + `slots` (khóa 5 phút, transaction khi xác nhận).
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, this.doctor});

  final DoctorEntity? doctor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingController(
        checkSlotAvailability: getIt<CheckSlotAvailabilityUseCase>(),
        lockSlot: getIt<LockSlotUseCase>(),
        releaseSlotLock: getIt<ReleaseSlotLockUseCase>(),
        confirmBooking: getIt<ConfirmBookingUseCase>(),
        joinWaitlist: getIt<JoinWaitlistUseCase>(),
        rescheduleBooking: getIt<RescheduleBookingUseCase>(),
        expireStaleUnpaidBookings: getIt<ExpireStaleUnpaidBookingsUseCase>(),
        initialDoctor: doctor,
      ),
      child: const _BookingView(),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────
class _BookingView extends StatefulWidget {
  const _BookingView();

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  final _specialtyCtrl  = TextEditingController();
  final _symptomsCtrl   = TextEditingController();
  String _lastSpecialty = '';
  int _selectedServiceIndex = 0;

  static const _serviceTypes = [
    (code: MedicalBookingTypes.clinic,    label: 'Khám tại cơ sở',     icon: Icons.local_hospital_rounded,    price: 350, bhyt: true),
    (code: MedicalBookingTypes.specialty, label: 'Khám chuyên khoa',    icon: Icons.medical_services_rounded,  price: 250, bhyt: true),
    (code: MedicalBookingTypes.test,      label: 'Xét nghiệm',          icon: Icons.science_rounded,           price: 180, bhyt: true),
    (code: MedicalBookingTypes.pharmacy,  label: 'Tư vấn dược',         icon: Icons.local_pharmacy_rounded,   price: 120, bhyt: false),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      final c    = context.read<BookingController>();
      _specialtyCtrl.text = c.specialtyText;
      c.initialize(auth.currentUser?.id ?? '');
    });
  }

  @override
  void dispose() {
    _specialtyCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDoctor() async {
    final picked = await Navigator.of(context).push<DoctorEntity>(
      MaterialPageRoute(builder: (_) => const DoctorSearchScreen(pickForBooking: true)),
    );
    if (!mounted || picked == null) return;
    context.read<BookingController>().setDoctor(picked);
    _specialtyCtrl.text = picked.specialty;
  }

  Future<void> _pickDate() async {
    final c = context.read<BookingController>();
    final d = await showDatePicker(
      context: context,
      initialDate: c.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: IColors.primary500),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: IColors.primary500),
          ),
        ),
        child: child!,
      ),
    );
    if (d != null && mounted) await c.onDateChanged(d);
  }

  Future<void> _confirm(BookingController c) async {
    HapticFeedback.mediumImpact();
    await c.confirmBooking();
    if (!mounted) return;
    if (c.flowState == BookingFlowState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Đặt lịch thành công! Mã QR check-in đã sẵn sàng.')),
          ]),
          backgroundColor: IColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (mounted && c.lastBooking != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AppointmentQrScreen(booking: c.lastBooking!)),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } else if (c.flowState == BookingFlowState.error && c.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(c.errorMessage!),
          backgroundColor: IColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: Consumer<BookingController>(
        builder: (_, c, __) {
          // Sync specialty text
          if (c.specialtyText != _lastSpecialty) {
            _lastSpecialty = c.specialtyText;
            if (_specialtyCtrl.text != c.specialtyText) _specialtyCtrl.text = c.specialtyText;
          }

          final isProcessing = c.flowState == BookingFlowState.bookingProcessing;
          final hasDoctor = c.doctor != null;
          final canBook = hasDoctor && !isProcessing && c.flowState != BookingFlowState.slotLoading;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Chọn bác sĩ
                          _buildSectionLabel('Bác sĩ khám'),
                          const SizedBox(height: 10),
                          hasDoctor
                              ? _DoctorSummaryCard(doctor: c.doctor!, onSwitch: _pickDoctor)
                              : _buildPickDoctorButton(),
                          const SizedBox(height: 22),

                          // ── Loại dịch vụ
                          _buildSectionLabel('Loại dịch vụ'),
                          const SizedBox(height: 10),
                          ..._serviceTypes.indexed.map((e) {
                            final i = e.$1;
                            final s = e.$2;
                            return _ServiceCard(
                              label: s.label,
                              icon: s.icon,
                              price: s.price,
                              bhyt: s.bhyt,
                              selected: _selectedServiceIndex == i,
                              onTap: () {
                                setState(() => _selectedServiceIndex = i);
                                c.setBookingType(s.code);
                              },
                            );
                          }),
                          const SizedBox(height: 22),

                          // ── Khoa khám
                          _buildSectionLabel('Khoa khám'),
                          const SizedBox(height: 10),
                          _buildSpecialtyField(c),
                          const SizedBox(height: 22),

                          // ── Chọn ngày
                          _buildSectionLabel('Chọn ngày khám'),
                          const SizedBox(height: 10),
                          _buildDateButton(c),
                          const SizedBox(height: 22),

                          // ── Khung giờ
                          Row(
                            children: [
                              _buildSectionLabel('Khung giờ trống'),
                              const Spacer(),
                              if (c.flowState == BookingFlowState.slotLoading)
                                const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: IColors.primary500,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (!hasDoctor)
                            _emptySlotNote('Chọn bác sĩ để xem lịch trống.')
                          else
                            _SlotSelectionGrid(controller: c),
                          if (c.lockedTimeSlot != null) ...[
                            const SizedBox(height: 10),
                            _buildLockTimer(c.lockedTimeSlot!),
                          ],
                          const SizedBox(height: 22),

                          // ── Triệu chứng
                          _buildSectionLabel('Lý do khám (tuỳ chọn)'),
                          const SizedBox(height: 10),
                          _buildSymptomsField(c),

                          // ── Error
                          if (c.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            _buildErrorBanner(c.errorMessage!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: _buildStickyBottom(c, canBook, isProcessing),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [IColors.primary100, IColors.bg],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(ctx),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: IColors.surface, shape: BoxShape.circle,
                        border: Border.all(color: IColors.line),
                        boxShadow: IColors.cardShadow,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: IColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ĐẶT LỊCH KHÁM', style: IText.label(size: 10, color: IColors.primary700)),
                      Text('Đặt lịch khám', style: IText.display(size: 20, color: IColors.ink)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Step indicators
              Row(
                children: List.generate(4, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i == 0 ? IColors.primary500 : IColors.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 6),
              Text('Bước 1/4 · Thông tin đặt khám', style: IText.label(size: 10, color: IColors.ink3)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String t) => Row(children: [
    Container(width: 3, height: 15, decoration: BoxDecoration(
      color: IColors.primary500, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(t.toUpperCase(), style: IText.label(color: IColors.ink2)),
  ]);

  // ─── Pick doctor button ────────────────────────────────────────────────────
  Widget _buildPickDoctorButton() {
    return GestureDetector(
      onTap: _pickDoctor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: IColors.primary100, width: 1.5),
          boxShadow: IColors.cardShadow,
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: IColors.primary50, borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_search_rounded, color: IColors.primary500, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Chọn bác sĩ', style: IText.body(size: 14, weight: FontWeight.w600, color: IColors.ink)),
            Text('Tìm và chọn bác sĩ phù hợp với bạn', style: IText.body(size: 12, color: IColors.ink3)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: IColors.ink3),
        ]),
      ),
    );
  }

  // ─── Specialty field ───────────────────────────────────────────────────────
  Widget _buildSpecialtyField(BookingController c) {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: TextField(
        controller: _specialtyCtrl,
        onChanged: c.setSpecialty,
        style: IText.body(size: 14),
        decoration: InputDecoration(
          hintText: 'VD: Tim mạch, Nội khoa, Da liễu...',
          hintStyle: IText.body(size: 13.5, color: IColors.ink3),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.local_hospital_outlined, color: IColors.primary500, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Date button ───────────────────────────────────────────────────────────
  Widget _buildDateButton(BookingController c) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: IColors.line),
          boxShadow: IColors.cardShadow,
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: IColors.primary50, borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: IColors.primary500, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('NGÀY KHÁM', style: IText.label(size: 10, color: IColors.ink3)),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(c.selectedDate),
              style: IText.body(size: 14, weight: FontWeight.w600, color: IColors.ink),
            ),
          ])),
          const Icon(Icons.chevron_right_rounded, color: IColors.ink3, size: 22),
        ]),
      ),
    );
  }

  // ─── Lock timer banner ─────────────────────────────────────────────────────
  Widget _buildLockTimer(String slot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: IColors.primary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IColors.primary100),
      ),
      child: Row(children: [
        const Icon(Icons.lock_clock_rounded, color: IColors.primary500, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Đang giữ khung $slot — Còn tối đa 5 phút',
          style: IText.body(size: 12.5, weight: FontWeight.w600, color: IColors.primary500),
        )),
      ]),
    );
  }

  // ─── Symptoms field ────────────────────────────────────────────────────────
  Widget _buildSymptomsField(BookingController c) {
    return Container(
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: TextField(
        controller: _symptomsCtrl,
        onChanged: c.setSymptoms,
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

  // ─── Error banner ──────────────────────────────────────────────────────────
  Widget _buildErrorBanner(String msg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: IColors.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: IText.body(size: 12.5, color: IColors.danger))),
      ]),
    );
  }

  // ─── Empty slot note ───────────────────────────────────────────────────────
  Widget _emptySlotNote(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: IColors.line2, borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: IColors.ink3, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: IText.body(size: 12.5, color: IColors.ink3)),
      ]),
    );
  }

  // ─── Sticky bottom CTA ─────────────────────────────────────────────────────
  Widget _buildStickyBottom(BookingController c, bool canBook, bool isProcessing) {
    final svc = _serviceTypes[_selectedServiceIndex];
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
                  c.doctor != null
                      ? '${c.doctor!.name} · ${DateFormat('dd/MM', 'vi').format(c.selectedDate)}'
                      : 'Chọn bác sĩ và giờ để tiếp tục',
                  style: IText.label(size: 11, color: Colors.white.withValues(alpha: 0.8)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    '${svc.price}.000đ',
                    style: IText.num(size: 20, weight: FontWeight.w800, color: Colors.white),
                  ),
                  if (svc.bhyt) ...[
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
              onTap: canBook ? () => _confirm(c) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: canBook ? Colors.white : Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  boxShadow: canBook
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 6))]
                      : [],
                ),
                child: isProcessing
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: canBook ? IColors.primary500 : Colors.white.withValues(alpha: 0.5),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        color: canBook ? IColors.primary500 : Colors.white.withValues(alpha: 0.5),
                        size: 24,
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Service Card ──────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int price;
  final bool bhyt;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.label,
    required this.icon,
    required this.price,
    required this.bhyt,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? IColors.primary50 : IColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? IColors.primary500 : IColors.line,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected ? IColors.cardShadow : [],
        ),
        child: Row(children: [
          // Radio dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? IColors.surface : Colors.transparent,
              border: Border.all(
                color: selected ? IColors.primary500 : IColors.ink200,
                width: selected ? 5.5 : 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: selected ? IColors.primary100 : IColors.line2,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: selected ? IColors.primary500 : IColors.ink3, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(label, style: IText.body(size: 14, weight: FontWeight.w600, color: IColors.ink)),
              if (bhyt) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: IColors.successBg, borderRadius: BorderRadius.circular(5)),
                  child: Text('BHYT', style: IText.label(size: 9, color: IColors.success)),
                ),
              ],
            ]),
            Text(bhyt ? 'Hỗ trợ bảo hiểm y tế' : 'Không áp dụng BHYT',
                style: IText.body(size: 11.5, color: IColors.ink3)),
          ])),
          Text('${price}K', style: IText.num(
            size: 16, weight: FontWeight.w800,
            color: selected ? IColors.primary500 : IColors.ink,
          )),
        ]),
      ),
    );
  }
}

// ─── Doctor Summary Card ────────────────────────────────────────────────────────
class _DoctorSummaryCard extends StatelessWidget {
  const _DoctorSummaryCard({required this.doctor, required this.onSwitch});

  final DoctorEntity doctor;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.primary100, width: 1.5),
        boxShadow: IColors.cardShadow,
      ),
      child: Row(children: [
        // Avatar with gradient
        Stack(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), IColors.primary700],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(child: Text(
              doctor.name.isNotEmpty ? doctor.name[0] : 'B',
              style: const TextStyle(
                fontFamily: IFont.interTight, fontSize: 20,
                fontWeight: FontWeight.w800, color: Colors.white,
              ),
            )),
          ),
          Positioned(right: -1, bottom: -1, child: Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: IColors.success, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 9),
          )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doctor.name.isNotEmpty ? doctor.name : 'Bác sĩ',
              style: IText.body(size: 14.5, weight: FontWeight.w700, color: IColors.ink)),
          Text(doctor.specialty.isNotEmpty ? doctor.specialty : '—',
              style: IText.body(size: 12.5, color: IColors.ink3)),
          if (doctor.displayClinic.isNotEmpty)
            Text(doctor.displayClinic, style: IText.body(size: 12, color: IColors.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        GestureDetector(
          onTap: onSwitch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: IColors.line2, borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Đổi', style: IText.body(size: 12.5, weight: FontWeight.w600, color: IColors.ink2)),
          ),
        ),
      ]),
    );
  }
}

// ─── Slot Selection Grid ──────────────────────────────────────────────────────
class _SlotSelectionGrid extends StatelessWidget {
  const _SlotSelectionGrid({required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final slots = controller.timeSlots;
    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: IColors.line2, borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, color: IColors.ink3, size: 16),
          const SizedBox(width: 8),
          Text('Không có khung giờ cho ngày này.', style: IText.body(size: 12.5, color: IColors.ink3)),
        ]),
      );
    }

    // Split into morning/afternoon
    final morning   = slots.where((s) { final h = _hour(s); return h >= 7 && h < 12; }).toList();
    final afternoon = slots.where((s) { final h = _hour(s); return h >= 12; }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) ...[
          _slotSectionHeader('CA SÁNG · 07:00 – 11:30'),
          const SizedBox(height: 10),
          _buildGrid(morning, context),
        ],
        if (afternoon.isNotEmpty) ...[
          const SizedBox(height: 14),
          _slotSectionHeader('CA CHIỀU · 13:00 – 17:00'),
          const SizedBox(height: 10),
          _buildGrid(afternoon, context),
        ],
        if (morning.isEmpty && afternoon.isEmpty)
          _buildGrid(slots, context),
      ],
    );
  }

  int _hour(String slot) {
    try { return int.parse(slot.split(':')[0]); } catch (_) { return 0; }
  }

  Widget _slotSectionHeader(String label) => Row(children: [
    Container(width: 3, height: 13, decoration: BoxDecoration(
      color: IColors.primary500, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 7),
    Text(label, style: IText.label(color: IColors.ink2)),
  ]);

  Widget _buildGrid(List<String> slots, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8, mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) => _buildSlot(slots[i], context),
    );
  }

  Widget _buildSlot(String slot, BuildContext context) {
    final av         = controller.slotAvailability[slot];
    final booked     = av?.kind == SlotAvailabilityKind.booked;
    final lockedOther = av?.kind == SlotAvailabilityKind.lockedByOther;
    final lockedSelf = av?.kind == SlotAvailabilityKind.lockedBySelf || controller.lockedTimeSlot == slot;
    final selectable = controller.isSlotSelectable(slot) || lockedSelf;
    final status     = controller.slotStatusLabel(slot);

    Color bg, borderColor, textColor;
    TextDecoration? deco;

    if (lockedSelf) {
      bg = IColors.primary500;
      borderColor = IColors.primary500;
      textColor = Colors.white;
    } else if (booked || lockedOther) {
      bg = IColors.line2;
      borderColor = IColors.line;
      textColor = IColors.ink200;
      deco = TextDecoration.lineThrough;
    } else {
      bg = IColors.surface;
      borderColor = IColors.line;
      textColor = IColors.ink;
    }

    return GestureDetector(
      onTap: () {
        if (booked || lockedOther) {
          _showUnavailableSheet(context, slot, booked, controller);
          return;
        }
        if (selectable) controller.selectTimeSlot(slot);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
          boxShadow: lockedSelf
              ? [BoxShadow(color: IColors.primary500.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(slot, style: TextStyle(
            fontFamily: IFont.interTight, fontSize: 12.5, fontWeight: FontWeight.w700,
            color: textColor, decoration: deco, decorationColor: IColors.ink200,
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
          if (status != null)
            Text(status, style: TextStyle(
              fontFamily: IFont.inter, fontSize: 9.5, color: lockedSelf ? Colors.white70 : IColors.ink3,
            )),
        ]),
      ),
    );
  }

  void _showUnavailableSheet(BuildContext context, String slot, bool booked, BookingController c) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: IColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: IColors.line, borderRadius: BorderRadius.circular(2)),
              alignment: Alignment.center,
            ),
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: booked ? IColors.dangerBg : IColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(booked ? Icons.block_rounded : Icons.lock_rounded,
                    color: booked ? IColors.danger : IColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slot, style: IText.num(size: 18, weight: FontWeight.w800, color: IColors.ink)),
                Text(
                  booked ? 'Khung giờ đã được đặt' : 'Đang được người khác giữ chỗ',
                  style: IText.body(size: 13, color: IColors.ink3),
                ),
              ])),
            ]),
            const SizedBox(height: 20),
            const Divider(color: IColors.line),
            const SizedBox(height: 16),
            if (booked)
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  await c.joinWaitlistForSlot(slot);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Đã thêm bạn vào danh sách chờ.'),
                      backgroundColor: IColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [IColors.primary500, IColors.primary700]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text('Tham gia danh sách chờ',
                      style: IText.body(size: 14, weight: FontWeight.w700, color: Colors.white))),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: IColors.line2, borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Vui lòng chọn khung giờ khác hoặc thử lại sau.',
                    style: IText.body(size: 13, color: IColors.ink2)),
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Center(child: Text('Đóng', style: IText.body(size: 13.5, weight: FontWeight.w600, color: IColors.ink2))),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

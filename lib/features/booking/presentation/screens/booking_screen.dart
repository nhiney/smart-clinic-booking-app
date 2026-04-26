import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import "package:smart_clinic_booking/shared/di/injection.dart";
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../../doctor/presentation/user/screens/doctor_search_screen.dart';
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
import 'package:smart_clinic_booking/shared/widgets/glass_morphic_container.dart';

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

class _BookingView extends StatefulWidget {
  const _BookingView();

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  final _specialtyCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String _lastSpecialty = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      final c = context.read<BookingController>();
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

  String _typeLabel(String code) {
    switch (code) {
      case MedicalBookingTypes.clinic:
        return 'Khám tại cơ sở';
      case MedicalBookingTypes.specialty:
        return 'Khám chuyên khoa';
      case MedicalBookingTypes.test:
        return 'Xét nghiệm';
      case MedicalBookingTypes.pharmacy:
        return 'Mua thuốc';
      case MedicalBookingTypes.enterprise:
        return 'Khám doanh nghiệp';
      default:
        return code;
    }
  }

  Future<void> _pickDoctor() async {
    final picked = await Navigator.of(context).push<DoctorEntity>(
      MaterialPageRoute(
        builder: (_) => const DoctorSearchScreen(pickForBooking: true),
      ),
    );
    if (!mounted || picked == null) return;
    context.read<BookingController>().setDoctor(picked);
    _specialtyCtrl.text = picked.specialty;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BookingController>();
    if (c.specialtyText != _lastSpecialty) {
      _lastSpecialty = c.specialtyText;
      if (_specialtyCtrl.text != c.specialtyText) {
        _specialtyCtrl.text = c.specialtyText;
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, c),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (c.doctor == null) ...[
                      _buildSectionTitle(context, 'Bác sĩ & Chuyên khoa'),
                      const SizedBox(height: 12),
                      _buildPickDoctorButton(context),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle(context, 'Thông tin đặt lịch'),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      context,
                      label: 'Loại dịch vụ',
                      value: c.selectedType,
                      items: MedicalBookingTypes.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
                          .toList(),
                      onChanged: (v) => v != null ? c.setBookingType(v) : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      label: 'Khoa khám',
                      controller: _specialtyCtrl,
                      onChanged: c.setSpecialty,
                      hint: 'Ví dụ: Tim mạch',
                      icon: Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Chọn ngày khám'),
                    const SizedBox(height: 12),
                    _HorizontalDatePicker(
                      selectedDate: c.selectedDate,
                      onDateSelected: (d) => c.onDateChanged(d),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildSectionTitle(context, 'Chọn khung giờ'),
                        const Spacer(),
                        if (c.flowState == BookingFlowState.slotLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (c.doctor == null)
                      _buildInfoNote(context, 'Vui lòng chọn bác sĩ để xem lịch trống.')
                    else
                      _SlotSelectionGrid(controller: c),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Triệu chứng & Ghi chú'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      context,
                      label: 'Mô tả triệu chứng',
                      controller: _symptomsCtrl,
                      onChanged: c.setSymptoms,
                      hint: 'Nhập tình trạng sức khỏe của bạn...',
                      maxLines: 3,
                      icon: Icons.notes_rounded,
                    ),
                    if (c.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorNote(context, c.errorMessage!),
                    ],
                  ]),
                ),
              ),
            ],
          ),
          _buildBottomAction(context, c),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, BookingController c) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.primary, context.colors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Đăng ký khám bệnh',
                    style: context.textStyles.heading2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  if (c.doctor != null)
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Bác sĩ: ${c.doctor!.name}',
                          style: context.textStyles.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Hoàn thành các bước để đặt lịch',
                      style: context.textStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textStyles.bodyBold.copyWith(
        color: context.colors.primaryDark,
        fontSize: 16,
      ),
    );
  }

  Widget _buildPickDoctorButton(BuildContext context) {
    return InkWell(
      onTap: _pickDoctor,
      borderRadius: context.radius.mRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.mRadius,
          border: Border.all(color: context.colors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: context.colors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search_rounded, color: context.colors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tìm bác sĩ theo yêu cầu', style: context.textStyles.bodyBold),
                  Text('Chọn bác sĩ phù hợp với chuyên khoa', style: context.textStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _fieldDecoration(context),
          items: items,
          onChanged: onChanged,
          style: context.textStyles.body,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: context.colors.primary),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: _fieldDecoration(context).copyWith(
            hintText: hint,
            prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
          ),
          style: context.textStyles.body,
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: context.colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: context.radius.mRadius,
        borderSide: BorderSide(color: context.colors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: context.radius.mRadius,
        borderSide: BorderSide(color: context.colors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: context.radius.mRadius,
        borderSide: BorderSide(color: context.colors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context, String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: context.radius.sRadius,
        border: Border.all(color: context.colors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.colors.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(note, style: context.textStyles.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildErrorNote(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.error.withOpacity(0.05),
        borderRadius: context.radius.sRadius,
        border: Border.all(color: context.colors.error.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: context.colors.error, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(error, style: context.textStyles.bodySmall.copyWith(color: context.colors.error))),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, BookingController c) {
    final canConfirm = c.doctor != null &&
        c.flowState != BookingFlowState.bookingProcessing &&
        c.flowState != BookingFlowState.slotLoading &&
        c.lockedTimeSlot != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GlassMorphicContainer(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c.lockedTimeSlot != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: context.colors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Đang giữ khung ${c.lockedTimeSlot} (tối đa 5 phút)',
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canConfirm
                    ? () async {
                        await c.confirmBooking();
                        if (!context.mounted) return;
                        final bc = context.read<BookingController>();
                        if (bc.flowState == BookingFlowState.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đặt lịch thành công! Mã QR check-in đã được tạo.'),
                              backgroundColor: context.colors.success,
                            ),
                          );
                          if (context.mounted && bc.lastBooking != null) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AppointmentQrScreen(
                                  booking: bc.lastBooking!,
                                ),
                              ),
                            );
                          }
                          if (context.mounted) Navigator.of(context).pop();
                        } else if (bc.flowState == BookingFlowState.error && bc.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(bc.errorMessage!), backgroundColor: context.colors.error),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: context.colors.textHint.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                  elevation: 0,
                ),
                child: c.flowState == BookingFlowState.bookingProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Xác nhận đặt lịch',
                        style: context.textStyles.bodyBold.copyWith(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _HorizontalDatePicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(30, (i) => DateTime.now().add(Duration(days: i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          final dayName = DateFormat('EEE', 'vi').format(date).toUpperCase();
          final dayNum = DateFormat('dd').format(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : context.colors.surface,
                borderRadius: context.radius.mRadius,
                border: Border.all(
                  color: isSelected ? context.colors.primary : context.colors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : context.colors.textPrimary,
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
}

class _SlotSelectionGrid extends StatelessWidget {
  const _SlotSelectionGrid({required this.controller});

  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final slots = controller.timeSlots;
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.mRadius,
          border: Border.all(color: context.colors.divider),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, color: context.colors.textHint, size: 40),
            const SizedBox(height: 12),
            Text(
              'Không có khung giờ cho ngày này.',
              style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final av = controller.slotAvailability[slot];
        final booked = av?.kind == SlotAvailabilityKind.booked;
        final lockedOther = av?.kind == SlotAvailabilityKind.lockedByOther;
        final lockedSelf = av?.kind == SlotAvailabilityKind.lockedBySelf ||
            controller.lockedTimeSlot == slot;
        final enabled = controller.isSlotSelectable(slot) || lockedSelf;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (!enabled && !booked && !lockedOther)
                ? null
                : () {
                    if (booked || lockedOther) {
                      _showSlotInfo(context, controller, slot, booked);
                      return;
                    }
                    controller.selectTimeSlot(slot);
                  },
            borderRadius: context.radius.sRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: lockedSelf
                    ? context.colors.primary
                    : (booked || lockedOther)
                        ? context.colors.divider.withOpacity(0.3)
                        : context.colors.surface,
                borderRadius: context.radius.sRadius,
                border: Border.all(
                  color: lockedSelf
                      ? context.colors.primary
                      : context.colors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: lockedSelf
                        ? Colors.white
                        : (booked || lockedOther)
                            ? context.colors.textHint
                            : context.colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSlotInfo(BuildContext context, BookingController controller, String slot, bool booked) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: booked ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    booked ? Icons.event_busy_rounded : Icons.lock_clock_rounded,
                    color: booked ? Colors.red : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    booked ? 'Khung giờ đã đầy' : 'Đang được xử lý',
                    style: context.textStyles.bodyBold.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              booked
                  ? 'Khung giờ này đã có bệnh nhân đặt lịch. Bạn có muốn tham gia danh sách chờ để nhận thông báo nếu có người hủy không?'
                  : 'Khung giờ này đang có người khác giữ chỗ để thực hiện thanh toán. Vui lòng quay lại sau ít phút.',
              style: context.textStyles.body,
            ),
            const SizedBox(height: 32),
            if (booked)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await controller.joinWaitlistForSlot(slot);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm bạn vào danh sách chờ.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                ),
                child: const Text('Tham gia danh sách chờ', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                ),
                child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}


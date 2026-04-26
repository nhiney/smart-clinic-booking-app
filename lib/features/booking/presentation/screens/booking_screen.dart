import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import "package:smart_clinic_booking/shared/di/injection.dart";
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../doctor/patient_pov//domain/entities/doctor_entity.dart';
import '../../../doctor/patient_pov//presentation/screens/doctor_search_screen.dart';
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
import '../../../../core/widgets/branded_app_bar.dart';

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

  Future<void> _pickDate() async {
    final c = context.read<BookingController>();
    final d = await showDatePicker(
      context: context,
      initialDate: c.selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d != null && mounted) {
      await c.onDateChanged(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(
        title: 'Đặt lịch khám',
        showBackButton: true,
      ),
      body: Consumer<BookingController>(
        builder: (_, c, __) {
          if (c.specialtyText != _lastSpecialty) {
            _lastSpecialty = c.specialtyText;
            if (_specialtyCtrl.text != c.specialtyText) {
              _specialtyCtrl.text = c.specialtyText;
            }
          }
          if (c.flowState == BookingFlowState.loading &&
              c.doctor == null &&
              c.slotAvailability.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (c.doctor == null) ...[
                      Text('Chọn bác sĩ', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDoctor,
                        icon: const Icon(Icons.person_search),
                        label: const Text('Tìm và chọn bác sĩ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      _DoctorSummaryCard(doctor: c.doctor!),
                      const SizedBox(height: 20),
                    ],
                    Text('Loại đặt lịch', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: c.selectedType,
                      decoration: _fieldDecoration(),
                      items: MedicalBookingTypes.values
                          .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
                          .toList(),
                      onChanged: (v) => v != null ? c.setBookingType(v) : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Khoa khám', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _specialtyCtrl,
                      onChanged: c.setSpecialty,
                      decoration: _fieldDecoration().copyWith(
                        hintText: 'Ví dụ: Tim mạch',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Ngày khám', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(c.selectedDate),
                              style: AppTextStyles.subtitle,
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Khung giờ', style: AppTextStyles.heading3),
                        const Spacer(),
                        if (c.flowState == BookingFlowState.slotLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (c.doctor == null)
                      Text(
                        'Chọn bác sĩ để xem lịch trống.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      )
                    else
                      _SlotSelectionGrid(controller: c),
                    const SizedBox(height: 16),
                    if (c.lockedTimeSlot != null)
                      Text(
                        'Đang giữ khung ${c.lockedTimeSlot} (tối đa 5 phút).',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text('Triệu chứng / ghi chú', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _symptomsCtrl,
                      onChanged: c.setSymptoms,
                      maxLines: 3,
                      decoration: _fieldDecoration().copyWith(
                        hintText: 'Mô tả triệu chứng...',
                      ),
                    ),
                    if (c.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        c.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: (c.doctor == null ||
                                c.flowState == BookingFlowState.bookingProcessing ||
                                c.flowState == BookingFlowState.slotLoading)
                            ? null
                            : () async {
                                await c.confirmBooking();
                                if (!context.mounted) return;
                                final bc = context.read<BookingController>();
                                if (bc.flowState == BookingFlowState.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đặt lịch thành công! Mã QR check-in đã được tạo.'),
                                      backgroundColor: AppColors.success,
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
                                    SnackBar(content: Text(bc.errorMessage!), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                        icon: c.flowState == BookingFlowState.bookingProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          c.flowState == BookingFlowState.bookingProcessing ? 'Đang xác nhận...' : 'Xác nhận đặt lịch',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
    );
  }
}

class _DoctorSummaryCard extends StatelessWidget {
  const _DoctorSummaryCard({required this.doctor});

  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primarySurface,
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: AppTextStyles.subtitle),
                Text(doctor.specialty, style: AppTextStyles.bodySmall),
                Text(
                  doctor.displayClinic,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await Navigator.of(context).push<DoctorEntity>(
                MaterialPageRoute(
                  builder: (_) => const DoctorSearchScreen(pickForBooking: true),
                ),
              );
              if (picked != null && context.mounted) {
                context.read<BookingController>().setDoctor(picked);
              }
            },
            child: const Text('Đổi'),
          ),
        ],
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
      return Text(
        'Không có khung giờ cho ngày này.',
        style:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final av = controller.slotAvailability[slot];
        final booked = av?.kind == SlotAvailabilityKind.booked;
        final lockedOther = av?.kind == SlotAvailabilityKind.lockedByOther;
        final lockedSelf = av?.kind == SlotAvailabilityKind.lockedBySelf ||
            controller.lockedTimeSlot == slot;
        final enabled = controller.isSlotSelectable(slot) || lockedSelf;
        final status = controller.slotStatusLabel(slot);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (!enabled && !booked && !lockedOther)
                    ? null
                    : () {
                        if (booked || lockedOther) {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    booked
                                        ? 'Khung giờ đã đặt'
                                        : 'Khung giờ đang được người khác giữ',
                                    style: AppTextStyles.subtitle,
                                  ),
                                  const SizedBox(height: 12),
                                  if (booked)
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        await controller
                                            .joinWaitlistForSlot(slot);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Đã thêm bạn vào danh sách chờ.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Tham gia danh sách chờ'),
                                    )
                                  else
                                    Text(
                                      'Vui lòng chọn khung giờ khác hoặc thử lại sau.',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          return;
                        }
                        controller.selectTimeSlot(slot);
                      },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: lockedSelf
                        ? AppColors.primary
                        : (booked || lockedOther)
                            ? AppColors.divider.withOpacity(0.35)
                            : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: lockedSelf
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: lockedSelf
                              ? Colors.white
                              : (booked || lockedOther)
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (status != null)
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 10,
                            color: lockedSelf
                                ? Colors.white70
                                : AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

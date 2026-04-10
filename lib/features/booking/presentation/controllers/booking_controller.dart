import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/check_slot_availability_usecase.dart';
import '../../domain/usecases/confirm_booking_usecase.dart';
import '../../domain/usecases/expire_stale_unpaid_bookings_usecase.dart';
import '../../domain/usecases/join_waitlist_usecase.dart';
import '../../domain/usecases/lock_slot_usecase.dart';
import '../../domain/usecases/release_slot_lock_usecase.dart';
import '../../domain/usecases/reschedule_booking_usecase.dart';
import '../utils/booking_slot_helper.dart';

enum BookingFlowState {
  initial,
  loading,
  slotLoading,
  slotLocked,
  bookingProcessing,
  success,
  error,
}

class BookingController extends ChangeNotifier {
  BookingController({
    required CheckSlotAvailabilityUseCase checkSlotAvailability,
    required LockSlotUseCase lockSlot,
    required ReleaseSlotLockUseCase releaseSlotLock,
    required ConfirmBookingUseCase confirmBooking,
    required JoinWaitlistUseCase joinWaitlist,
    required RescheduleBookingUseCase rescheduleBooking,
    required ExpireStaleUnpaidBookingsUseCase expireStaleUnpaidBookings,
    DoctorEntity? initialDoctor,
  })  : _checkSlotAvailability = checkSlotAvailability,
        _lockSlot = lockSlot,
        _releaseSlotLock = releaseSlotLock,
        _confirmBooking = confirmBooking,
        _joinWaitlist = joinWaitlist,
        _rescheduleBooking = rescheduleBooking,
        _expireStaleUnpaidBookings = expireStaleUnpaidBookings,
        _doctor = initialDoctor {
    if (initialDoctor != null && initialDoctor.specialty.isNotEmpty) {
      specialtyText = initialDoctor.specialty;
    }
    timeSlots = resolveTimeSlotsForDate(_doctor, selectedDate);
  }

  final CheckSlotAvailabilityUseCase _checkSlotAvailability;
  final LockSlotUseCase _lockSlot;
  final ReleaseSlotLockUseCase _releaseSlotLock;
  final ConfirmBookingUseCase _confirmBooking;
  final JoinWaitlistUseCase _joinWaitlist;
  final RescheduleBookingUseCase _rescheduleBooking;
  final ExpireStaleUnpaidBookingsUseCase _expireStaleUnpaidBookings;

  DoctorEntity? _doctor;
  DoctorEntity? get doctor => _doctor;

  String userId = '';
  BookingFlowState flowState = BookingFlowState.initial;
  String? errorMessage;
  String selectedType = MedicalBookingTypes.clinic;
  String specialtyText = '';
  String symptomsText = '';
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(const Duration(days: 1));

  List<String> timeSlots = [];
  Map<String, SlotAvailability> slotAvailability = {};
  String? lockedTimeSlot;
  BookingEntity? lastBooking;

  void setDoctor(DoctorEntity? value) {
    _doctor = value;
    specialtyText = value?.specialty ?? specialtyText;
    lockedTimeSlot = null;
    timeSlots = resolveTimeSlotsForDate(_doctor, selectedDate);
    slotAvailability = {};
    notifyListeners();
    if (userId.isNotEmpty && _doctor != null) {
      refreshSlotAvailability();
    }
  }

  void setBookingType(String type) {
    selectedType = type;
    notifyListeners();
  }

  void setSpecialty(String value) {
    specialtyText = value;
    notifyListeners();
  }

  void setSymptoms(String value) {
    symptomsText = value;
    notifyListeners();
  }

  Future<void> initialize(String uid) async {
    userId = uid;
    if (userId.isEmpty) {
      flowState = BookingFlowState.error;
      errorMessage = 'Vui lòng đăng nhập để đặt lịch.';
      notifyListeners();
      return;
    }

    flowState = BookingFlowState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        await _expireStaleUnpaidBookings(userId);
      } catch (e) {
        debugPrint('[Booking] expireStaleUnpaidBookings: $e');
      }
      timeSlots = resolveTimeSlotsForDate(_doctor, selectedDate);
      if (_doctor != null) {
        await refreshSlotAvailability();
      } else {
        flowState = BookingFlowState.initial;
      }
    } catch (e) {
      flowState = BookingFlowState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> onDateChanged(DateTime date) async {
    final d = DateTime(date.year, date.month, date.day);
    if (lockedTimeSlot != null && _doctor != null) {
      await _releaseSlotLock(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlot: lockedTimeSlot!,
      );
      lockedTimeSlot = null;
    }
    selectedDate = d;
    timeSlots = resolveTimeSlotsForDate(_doctor, selectedDate);
    slotAvailability = {};
    notifyListeners();
    if (_doctor != null) {
      await refreshSlotAvailability();
    }
  }

  Future<void> refreshSlotAvailability() async {
    if (_doctor == null || userId.isEmpty) return;
    flowState = BookingFlowState.slotLoading;
    errorMessage = null;
    notifyListeners();
    try {
      slotAvailability = await _checkSlotAvailability(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlots: timeSlots,
      );
      flowState = lockedTimeSlot != null
          ? BookingFlowState.slotLocked
          : BookingFlowState.initial;
    } catch (e) {
      flowState = BookingFlowState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> selectTimeSlot(String slot) async {
    if (_doctor == null || userId.isEmpty) return;
    final av = slotAvailability[slot];
    if (av?.kind == SlotAvailabilityKind.booked) {
      errorMessage = 'Khung giờ đã được đặt. Bạn có thể tham gia danh sách chờ.';
      notifyListeners();
      return;
    }
    if (av?.kind == SlotAvailabilityKind.lockedByOther) {
      errorMessage =
          'Khung giờ đang được người khác giữ. Chọn giờ khác hoặc thử lại sau.';
      notifyListeners();
      return;
    }

    if (lockedTimeSlot != null && lockedTimeSlot != slot) {
      await _releaseSlotLock(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlot: lockedTimeSlot!,
      );
      lockedTimeSlot = null;
    }

    flowState = BookingFlowState.slotLoading;
    errorMessage = null;
    notifyListeners();

    try {
      await _lockSlot(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlot: slot,
      );
      lockedTimeSlot = slot;
      flowState = BookingFlowState.slotLocked;
      await refreshSlotAvailability();
    } catch (e) {
      flowState = BookingFlowState.error;
      errorMessage = _mapError(e);
      lockedTimeSlot = null;
      await refreshSlotAvailability();
    }
    notifyListeners();
  }

  Future<void> joinWaitlistForSlot(String slot) async {
    if (_doctor == null || userId.isEmpty) return;
    flowState = BookingFlowState.loading;
    notifyListeners();
    try {
      await _joinWaitlist(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlot: slot,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      flowState = BookingFlowState.initial;
      notifyListeners();
    }
  }

  Future<void> confirmBooking() async {
    if (_doctor == null || userId.isEmpty) return;
    if (lockedTimeSlot == null) {
      errorMessage = 'Vui lòng chọn và giữ một khung giờ trước khi xác nhận.';
      notifyListeners();
      return;
    }
    if (specialtyText.trim().isEmpty) {
      errorMessage = 'Vui lòng chọn / nhập khoa khám.';
      notifyListeners();
      return;
    }

    flowState = BookingFlowState.bookingProcessing;
    errorMessage = null;
    notifyListeners();

    try {
      lastBooking = await _confirmBooking(
        userId: userId,
        doctorId: _doctor!.id,
        type: selectedType,
        specialty: specialtyText.trim(),
        symptoms: symptomsText.trim(),
        date: selectedDate,
        timeSlot: lockedTimeSlot!,
      );
      lockedTimeSlot = null;
      flowState = BookingFlowState.success;
      await refreshSlotAvailability();
    } catch (e) {
      flowState = BookingFlowState.error;
      errorMessage = _mapError(e);
      await refreshSlotAvailability();
    }
    notifyListeners();
  }

  /// Reschedule an existing booking (e.g. from history). Uses Firestore transaction.
  Future<BookingEntity?> reschedule({
    required String bookingId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    if (_doctor == null || userId.isEmpty) return null;
    flowState = BookingFlowState.bookingProcessing;
    errorMessage = null;
    notifyListeners();
    try {
      final b = await _rescheduleBooking(
        bookingId: bookingId,
        userId: userId,
        doctorId: _doctor!.id,
        newDate: newDate,
        newTimeSlot: newTimeSlot,
      );
      lastBooking = b;
      flowState = BookingFlowState.success;
      notifyListeners();
      return b;
    } catch (e) {
      flowState = BookingFlowState.error;
      errorMessage = _mapError(e);
      notifyListeners();
      return null;
    }
  }

  Future<void> releaseCurrentLock() async {
    if (lockedTimeSlot == null || _doctor == null || userId.isEmpty) return;
    try {
      await _releaseSlotLock(
        userId: userId,
        doctorId: _doctor!.id,
        date: selectedDate,
        timeSlot: lockedTimeSlot!,
      );
    } catch (_) {}
    lockedTimeSlot = null;
    flowState = BookingFlowState.initial;
    await refreshSlotAvailability();
    notifyListeners();
  }

  String _mapError(Object e) {
    if (e is StateError) {
      switch (e.message) {
        case 'SLOT_BOOKED':
          return 'Khung giờ đã có người đặt.';
        case 'SLOT_LOCKED_BY_OTHER':
          return 'Khung giờ đang được giữ bởi người khác.';
        case 'SLOT_NOT_YOUR_LOCK':
          return 'Bạn chưa giữ khung giờ này. Chọn lại khung giờ.';
        case 'SLOT_LOCK_EXPIRED':
          return 'Thời gian giữ lịch đã hết. Chọn lại khung giờ.';
        case 'SLOT_LOCK_MISSING':
          return 'Không tìm thấy khóa khung giờ. Chọn lại khung giờ.';
        case 'NEW_SLOT_BOOKED':
          return 'Khung giờ mới không còn trống.';
        case 'NEW_SLOT_LOCKED':
          return 'Khung giờ mới đang được giữ.';
        case 'BOOKING_NOT_FOUND':
          return 'Không tìm thấy lịch hẹn.';
        case 'NOT_OWNER':
          return 'Bạn không có quyền thao tác lịch này.';
        case 'BOOKING_SLOT_UNKNOWN':
          return 'Dữ liệu lịch không hợp lệ.';
      }
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }

  bool isSlotSelectable(String slot) {
    final av = slotAvailability[slot];
    if (av == null) return true;
    switch (av.kind) {
      case SlotAvailabilityKind.available:
      case SlotAvailabilityKind.lockExpired:
        return true;
      case SlotAvailabilityKind.lockedBySelf:
        return true;
      case SlotAvailabilityKind.booked:
      case SlotAvailabilityKind.lockedByOther:
        return false;
    }
  }

  String? slotStatusLabel(String slot) {
    final av = slotAvailability[slot];
    switch (av?.kind) {
      case SlotAvailabilityKind.booked:
        return 'Đã đặt';
      case SlotAvailabilityKind.lockedByOther:
        return 'Đang giữ';
      case SlotAvailabilityKind.lockedBySelf:
        return 'Bạn đang giữ';
      case SlotAvailabilityKind.lockExpired:
      case SlotAvailabilityKind.available:
      case null:
        return null;
    }
  }

  @override
  void dispose() {
    final slot = lockedTimeSlot;
    final doc = _doctor;
    final uid = userId;
    final date = selectedDate;
    if (slot != null && doc != null && uid.isNotEmpty) {
      unawaited(
        _releaseSlotLock(
          userId: uid,
          doctorId: doc.id,
          date: date,
          timeSlot: slot,
        ),
      );
    }
    super.dispose();
  }
}

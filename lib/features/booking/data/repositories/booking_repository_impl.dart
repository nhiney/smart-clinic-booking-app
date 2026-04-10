import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDatasource _remote;

  @override
  Future<Map<String, SlotAvailability>> checkSlotsAvailability({
    required String userId,
    required String doctorId,
    required DateTime date,
    required List<String> timeSlots,
  }) {
    return _remote.checkSlotsAvailability(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlots: timeSlots,
    );
  }

  @override
  Future<void> lockSlot({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) {
    return _remote.lockSlot(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
  }

  @override
  Future<void> releaseSlotLock({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) {
    return _remote.releaseSlotLock(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
  }

  @override
  Future<BookingEntity> confirmBooking({
    required String userId,
    required String doctorId,
    required String type,
    required String specialty,
    required String symptoms,
    required DateTime date,
    required String timeSlot,
    Duration bookingTtlUnpaid = const Duration(hours: 24),
  }) {
    return _remote.confirmBooking(
      userId: userId,
      doctorId: doctorId,
      type: type,
      specialty: specialty,
      symptoms: symptoms,
      date: date,
      timeSlot: timeSlot,
      bookingTtlUnpaid: bookingTtlUnpaid,
    );
  }

  @override
  Future<void> joinWaitlist({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) {
    return _remote.joinWaitlist(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
  }

  @override
  Future<BookingEntity> rescheduleBooking({
    required String bookingId,
    required String userId,
    required String doctorId,
    required DateTime newDate,
    required String newTimeSlot,
    Duration bookingTtlUnpaid = const Duration(hours: 24),
  }) {
    return _remote.rescheduleBooking(
      bookingId: bookingId,
      userId: userId,
      doctorId: doctorId,
      newDate: newDate,
      newTimeSlot: newTimeSlot,
      bookingTtlUnpaid: bookingTtlUnpaid,
    );
  }

  @override
  Future<int> expireStaleUnpaidBookings(String userId) {
    return _remote.expireStaleUnpaidBookings(userId);
  }
}

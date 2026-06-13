import '../entities/booking_entity.dart';

abstract class BookingRepository {
  /// Parallel reads for known [timeSlots] on [date].
  Future<Map<String, SlotAvailability>> checkSlotsAvailability({
    required String userId,
    required String doctorId,
    required DateTime date,
    required List<String> timeSlots,
  });

  Future<void> lockSlot({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  });

  Future<void> releaseSlotLock({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  });

  /// Transaction: validate lock, write booking, mark slot booked.
  Future<BookingEntity> confirmBooking({
    required String userId,
    required String doctorId,
    required String type,
    required String specialty,
    required String symptoms,
    required DateTime date,
    required String timeSlot,
    Duration bookingTtlUnpaid,
  });

  Future<void> joinWaitlist({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  });

  /// Release old slot, lock+confirm path for new slot in one transaction.
  Future<BookingEntity> rescheduleBooking({
    required String bookingId,
    required String userId,
    required String doctorId,
    required DateTime newDate,
    required String newTimeSlot,
    Duration bookingTtlUnpaid,
  });

  /// Client-side: cancel unpaid expired bookings for user and free slots.
  Future<int> expireStaleUnpaidBookings(String userId);
}

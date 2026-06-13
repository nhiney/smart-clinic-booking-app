import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class RescheduleBookingUseCase {
  RescheduleBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<BookingEntity> call({
    required String bookingId,
    required String userId,
    required String doctorId,
    required DateTime newDate,
    required String newTimeSlot,
    Duration bookingTtlUnpaid = const Duration(hours: 24),
  }) {
    return _repository.rescheduleBooking(
      bookingId: bookingId,
      userId: userId,
      doctorId: doctorId,
      newDate: newDate,
      newTimeSlot: newTimeSlot,
      bookingTtlUnpaid: bookingTtlUnpaid,
    );
  }
}

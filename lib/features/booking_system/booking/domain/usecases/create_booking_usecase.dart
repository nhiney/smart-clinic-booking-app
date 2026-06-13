import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// Same as [ConfirmBookingUseCase] — creates the Firestore booking document.
class CreateBookingUseCase {
  CreateBookingUseCase(this._repository);

  final BookingRepository _repository;

  Future<BookingEntity> call({
    required String userId,
    required String doctorId,
    required String type,
    required String specialty,
    required String symptoms,
    required DateTime date,
    required String timeSlot,
    Duration bookingTtlUnpaid = const Duration(hours: 24),
  }) {
    return _repository.confirmBooking(
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
}

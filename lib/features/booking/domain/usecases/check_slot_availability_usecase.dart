import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CheckSlotAvailabilityUseCase {
  CheckSlotAvailabilityUseCase(this._repository);

  final BookingRepository _repository;

  Future<Map<String, SlotAvailability>> call({
    required String userId,
    required String doctorId,
    required DateTime date,
    required List<String> timeSlots,
  }) {
    return _repository.checkSlotsAvailability(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlots: timeSlots,
    );
  }
}

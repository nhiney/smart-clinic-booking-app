import '../repositories/booking_repository.dart';

class LockSlotUseCase {
  LockSlotUseCase(this._repository);

  final BookingRepository _repository;

  Future<void> call({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) {
    return _repository.lockSlot(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
  }
}

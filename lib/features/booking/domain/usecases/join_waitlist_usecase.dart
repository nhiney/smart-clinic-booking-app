import '../repositories/booking_repository.dart';

class JoinWaitlistUseCase {
  JoinWaitlistUseCase(this._repository);

  final BookingRepository _repository;

  Future<void> call({
    required String userId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) {
    return _repository.joinWaitlist(
      userId: userId,
      doctorId: doctorId,
      date: date,
      timeSlot: timeSlot,
    );
  }
}

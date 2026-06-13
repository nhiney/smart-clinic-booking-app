import '../repositories/booking_repository.dart';

class ExpireStaleUnpaidBookingsUseCase {
  ExpireStaleUnpaidBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<int> call(String userId) {
    return _repository.expireStaleUnpaidBookings(userId);
  }
}

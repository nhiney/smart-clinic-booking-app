/// Các ngoại lệ đặc thù cho hệ thống Kiosk
class KioskException implements Exception {
  final String message;
  KioskException(this.message);

  @override
  String toString() => 'KioskException: $message';
}

/// Ngoại lệ khi slot đã bị người khác đặt mất (xử lý concurrency)
class SlotAlreadyBookedException extends KioskException {
  SlotAlreadyBookedException() 
    : super('Khung giờ này vừa có người đặt. Vui lòng chọn khung giờ khác.');
}

/// Ngoại lệ liên quan đến xác thực thiết bị
class KioskAuthException extends KioskException {
  KioskAuthException(String message) : super(message);
}

/// Ngoại lệ khi mất kết nối mạng
class KioskNetworkException extends KioskException {
  KioskNetworkException() : super('Hệ thống đang bảo trì kết nối. Vui lòng liên hệ quầy lễ tân.');
}

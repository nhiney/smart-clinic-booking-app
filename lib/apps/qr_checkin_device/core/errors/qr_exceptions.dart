/// Ngoại lệ cơ sở cho module QR Check-in
class QRCheckInException implements Exception {
  final String message;
  QRCheckInException(this.message);

  @override
  String toString() => message;
}

/// Mã QR không hợp lệ hoặc không tồn tại trong hệ thống
class InvalidQRCodeException extends QRCheckInException {
  InvalidQRCodeException() : super('Mã QR không hợp lệ hoặc đã hết hạn.');
}

/// Bệnh nhân đã thực hiện check-in trước đó rồi
class AlreadyCheckedInException extends QRCheckInException {
  AlreadyCheckedInException() : super('Bạn đã thực hiện check-in cho lịch hẹn này rồi.');
}

/// Check-in quá sớm (trước hơn 60 phút)
class TooEarlyException extends QRCheckInException {
  TooEarlyException() : super('Chưa đến giờ check-in. Vui lòng quay lại sau.');
}

/// Lỗi kết nối mạng
class QRNetworkException extends QRCheckInException {
  QRNetworkException() : super('Hệ thống đang bảo trì kết nối. Vui lòng liên hệ quầy lễ tân.');
}

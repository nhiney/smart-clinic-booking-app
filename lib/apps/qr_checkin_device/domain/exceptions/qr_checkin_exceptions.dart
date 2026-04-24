class QrCheckInException implements Exception {
  final String message;
  QrCheckInException(this.message);

  @override
  String toString() => message;
}

class InvalidQRCodeException extends QrCheckInException {
  InvalidQRCodeException() : super('Mã QR không hợp lệ hoặc không tồn tại trong hệ thống.');
}

class AlreadyCheckedInException extends QrCheckInException {
  AlreadyCheckedInException() : super('Bệnh nhân này đã thực hiện Check-in trước đó.');
}

class TooEarlyException extends QrCheckInException {
  final int minutesRemaining;
  TooEarlyException(this.minutesRemaining)
      : super('Còn quá sớm để Check-in. Vui lòng quay lại trước giờ hẹn 60 phút (còn $minutesRemaining phút).');
}

class ExpiredQRCodeException extends QrCheckInException {
  ExpiredQRCodeException() : super('Mã QR đã hết hạn. Vui lòng liên hệ quầy lễ tân để được hỗ trợ.');
}

class FakeQRCodeException extends QrCheckInException {
  FakeQRCodeException() : super('Mã QR bị giả mạo hoặc chưa được cấp phép. Check-in bị từ chối.');
}

import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/entities/check_in_result_entity.dart';

abstract class QRCheckInState {
  const QRCheckInState();
}

class QRCheckInIdle extends QRCheckInState {
  const QRCheckInIdle();
}

class QRCheckInProcessing extends QRCheckInState {
  const QRCheckInProcessing();
}

class QRCheckInSuccess extends QRCheckInState {
  final CheckInResultEntity result;
  const QRCheckInSuccess(this.result);
}

class QRCheckInFailure extends QRCheckInState {
  final String message;
  const QRCheckInFailure(this.message);
}

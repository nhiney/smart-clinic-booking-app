import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/features/checkin/presentation/controllers/checkin_controller.dart';

void main() {
  group('CheckInNotifier', () {
    test(
        'generates QR with spec-aligned validity window when appointment time exists',
        () {
      final notifier = CheckInNotifier();
      final appointmentTime = DateTime(2026, 4, 9, 10, 0);

      notifier.generateQR(
        'user-1',
        'appointment-1',
        appointmentTime: appointmentTime,
      );

      expect(
        notifier.state.validFrom,
        appointmentTime.subtract(const Duration(hours: 2)),
      );
      expect(
        notifier.state.expiry,
        appointmentTime.add(const Duration(minutes: 5)),
      );
      expect(notifier.state.qrData, isNotEmpty);
    });

    test('validity check rejects scans outside the QR window', () {
      final notifier = CheckInNotifier();
      final appointmentTime = DateTime(2026, 4, 9, 10, 0);

      notifier.generateQR(
        'user-1',
        'appointment-1',
        appointmentTime: appointmentTime,
      );

      expect(
        notifier.isWithinValidityWindow(DateTime(2026, 4, 9, 7, 59)),
        isFalse,
      );
      expect(
        notifier.isWithinValidityWindow(DateTime(2026, 4, 9, 10, 4)),
        isTrue,
      );
    });
  });
}

// Demo VIDEO — vai trò BÁC SĨ, chi tiết tất cả tính năng, kèm phụ đề.
// flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/doctor_demo_video_test.dart -d <iPhone-UDID>

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const doctorEmail = 'annv.choray@icare.com';
const doctorPassword = 'Icare@123';
const testPatientId = '3iZGxvL2GcZMRsGMHR5ItNYnZRW2';

late IntegrationTestWidgetsFlutterBinding binding;

Future<void> beat(WidgetTester tester, int ms) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void step(String caption) {
  // ignore: avoid_print
  print('[STEP] $caption');
}

Future<void> scrollDown(WidgetTester tester, {double dy = -440, int hold = 2200}) async {
  final sc = find.byType(Scrollable);
  if (sc.evaluate().isNotEmpty) {
    await tester.drag(sc.first, Offset(0, dy), warnIfMissed: false);
    await beat(tester, hold);
  }
}

Future<void> feature(WidgetTester tester, String caption, String route,
    {int hold = 3600, bool scroll = false, bool scroll2 = false}) async {
  try {
    AppRouter.router.go('/doctor/dashboard');
    await beat(tester, 800);
    AppRouter.router.push(route);
    await beat(tester, 1600);
    step(caption);
    await beat(tester, hold);
    if (scroll) await scrollDown(tester);
    if (scroll2) await scrollDown(tester, dy: -480);
  } catch (e) {
    // ignore: avoid_print
    print('[FEATURE-ERR] $route: $e');
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bác sĩ DEMO video - chi tiết tất cả tính năng + chú thích',
      (tester) async {
    await app.main();
    await beat(tester, 5000);

    // ignore: avoid_print
    print('[DEMO-READY]');
    await beat(tester, 2500);

    // ───── ĐĂNG NHẬP BÁC SĨ ─────
    step('Màn đăng nhập nhân viên / bác sĩ');
    AppRouter.router.go('/staff-login');
    await beat(tester, 3000);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: doctorEmail, password: doctorPassword);
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN-DOCTOR] $e');
    }
    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await beat(tester, 7000);

    AppRouter.router.go('/doctor/dashboard');
    await beat(tester, 4000);

    // ───── DASHBOARD ─────
    step('Bảng điều khiển bác sĩ — lịch hẹn & thống kê hôm nay');
    await beat(tester, 3600);
    step('Tổng quan — thống kê tuần & lịch hẹn sắp tới');
    await scrollDown(tester, dy: -480, hold: 2600);
    await scrollDown(tester, dy: -480, hold: 2400);
    await scrollDown(tester, dy: 1800, hold: 600);

    // ───── CÁC TÍNH NĂNG ─────
    await feature(tester, 'Hồ sơ & không gian làm việc của bác sĩ', '/doctor/profile', scroll: true);
    await feature(tester, 'Lịch làm việc — timeline lịch hẹn trong ngày', '/doctor/schedule', scroll: true);
    await feature(tester, 'Danh sách bệnh nhân hôm nay', '/doctor/schedule-list', scroll: true);
    await feature(tester, 'Cài đặt khung giờ làm việc', '/doctor/schedule-settings', scroll: true);
    await feature(tester, 'Thu nhập — doanh thu & thống kê theo thời gian', '/doctor/income', scroll: true);
    await feature(tester, 'Thống kê hiệu suất khám bệnh', '/doctor/analytics', scroll: true);

    // hồ sơ bệnh nhân + SOAP + chat (cần patientId)
    await feature(tester, 'Hồ sơ bệnh nhân (góc nhìn bác sĩ)', '/doctor/patient/$testPatientId', scroll: true);
    await feature(tester, 'Khám bệnh — ghi chú lâm sàng SOAP (S.O.A.P)', '/doctor/soap/$testPatientId', scroll: true, scroll2: true);
    await feature(tester, 'Trò chuyện & tư vấn với bệnh nhân', '/doctor/chat/$testPatientId');

    await beat(tester, 1500);
    // ignore: avoid_print
    print('XONG - DEMO hoàn tất');
    await beat(tester, 1000);
  }, timeout: Timeout.none);
}

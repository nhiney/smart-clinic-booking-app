// Chụp đầy đủ các màn hình VAI TRÒ BÁC SĨ từng bước.
// Chạy:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/doctor_features_test.dart \
//     --screenshot test_screenshots/doctor -d <UDID>

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const doctorEmail    = 'annv.choray@icare.com';
const doctorPassword = 'Icare@123';

// Test patient UID (tài khoản bệnh nhân seeded sẵn)
const testPatientId = '3iZGxvL2GcZMRsGMHR5ItNYnZRW2';

late IntegrationTestWidgetsFlutterBinding binding;

Future<void> settle(WidgetTester tester, {int ms = 1500}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> shot(WidgetTester tester, String name) async {
  await settle(tester, ms: 2500);
  try {
    await binding.takeScreenshot(name);
    // ignore: avoid_print
    print('[SHOT] $name');
  } catch (e) {
    // ignore: avoid_print
    print('[SHOT-FAIL] $name: $e');
  }
}

Future<void> nav(WidgetTester tester, String route) async {
  AppRouter.router.push(route);
  await settle(tester, ms: 4000);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bác sĩ - toàn bộ tính năng, chụp từng bước', (tester) async {
    await app.main();
    await settle(tester, ms: 5000);

    // ─── Bước 0: Chụp màn hình đăng nhập nhân viên ────────────────────────
    AppRouter.router.go('/staff-login');
    await settle(tester, ms: 2000);
    await shot(tester, 'D01_staff_login');

    // ─── Bước 1: Đăng nhập bác sĩ ──────────────────────────────────────────
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: doctorEmail, password: doctorPassword);
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN-DOCTOR] $e');
    }
    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await settle(tester, ms: 7000);

    // Router sẽ redirect về /doctor/dashboard khi role == doctor
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 6000);

    // ─── Bước 2: Dashboard bác sĩ ──────────────────────────────────────────
    await shot(tester, 'D02_doctor_dashboard');

    // ─── Bước 3: Hồ sơ / Workspace bác sĩ ────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/profile');
    await shot(tester, 'D03_doctor_ho_so');

    // ─── Bước 4: Lịch làm việc (timeline) ────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/schedule');
    await shot(tester, 'D04_doctor_lich_lam_viec');

    // ─── Bước 5: Danh sách bệnh nhân hôm nay ────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/schedule-list');
    await shot(tester, 'D05_doctor_danh_sach_benh_nhan');

    // ─── Bước 6: Cài đặt khung giờ ──────────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/schedule-settings');
    await shot(tester, 'D06_doctor_cai_dat_lich');

    // ─── Bước 7: Thu nhập ───────────────────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/income');
    await shot(tester, 'D07_doctor_thu_nhap');

    // ─── Bước 8: Thống kê hiệu suất ─────────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    await nav(tester, '/doctor/analytics');
    await shot(tester, 'D08_doctor_thong_ke');

    // ─── Bước 9: Hồ sơ bệnh nhân (doctor POV) ──────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    AppRouter.router.push('/doctor/patient/$testPatientId');
    await settle(tester, ms: 4000);
    await shot(tester, 'D09_doctor_ho_so_benh_nhan');

    // ─── Bước 10: Ghi chú lâm sàng SOAP ────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    AppRouter.router.push('/doctor/soap/$testPatientId');
    await settle(tester, ms: 4000);
    await shot(tester, 'D10_doctor_soap_kham_benh');

    // ─── Bước 11: Nhắn tin với bệnh nhân ────────────────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 1000);
    AppRouter.router.push('/doctor/chat/$testPatientId');
    await settle(tester, ms: 4000);
    await shot(tester, 'D11_doctor_chat_benh_nhan');

    // ─── Bước 12: Dashboard lần cuối (scroll xuống) ─────────────────────
    AppRouter.router.go('/doctor/dashboard');
    await settle(tester, ms: 3000);
    // Scroll xuống để thấy thêm nội dung
    await tester.drag(find.byType(Scaffold).first, const Offset(0, -400));
    await settle(tester, ms: 1500);
    await shot(tester, 'D12_doctor_dashboard_cuon');

    // ignore: avoid_print
    print('XONG - Toàn bộ màn hình bác sĩ đã chụp xong');
  }, timeout: Timeout.none);
}

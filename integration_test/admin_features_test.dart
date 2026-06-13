// Chụp toàn bộ màn hình VAI TRÒ ADMIN từng bước.
// Chạy:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/admin_features_test.dart \
//     --screenshot test_screenshots/admin -d <UDID>

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const adminEmail    = 'admin@icare.com';
const adminPassword = 'Icare@123';

late IntegrationTestWidgetsFlutterBinding binding;

Future<void> settle(WidgetTester tester, {int ms = 1500}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> shot(WidgetTester tester, String name) async {
  await settle(tester, ms: 3000);
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

/// Tap bottom nav item by label text
Future<void> tapBottomNavLabel(WidgetTester tester, String label) async {
  final item = find.text(label);
  if (item.evaluate().isNotEmpty) {
    await tester.tap(item.first);
    await settle(tester, ms: 3000);
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin - toàn bộ tính năng, chụp từng bước', (tester) async {
    await app.main();
    await settle(tester, ms: 5000);

    // ─── A01: Màn hình đăng nhập nhân viên ──────────────────────────────────
    AppRouter.router.go('/staff-login');
    await settle(tester, ms: 2000);
    await shot(tester, 'A01_staff_login');

    // ─── Đăng nhập admin ────────────────────────────────────────────────────
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail, password: adminPassword);
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN-ADMIN] $e');
    }
    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await settle(tester, ms: 7000);

    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 6000);

    // ─── A02: Tổng quan (Dashboard) ─────────────────────────────────────────
    await shot(tester, 'A02_admin_dashboard');

    // ─── A03: Dashboard cuộn xuống ───────────────────────────────────────────
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await settle(tester, ms: 1500);
    await shot(tester, 'A03_admin_dashboard_cuon');

    // ─── A04: Tab Bệnh viện ──────────────────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 3000);
    await tapBottomNavLabel(tester, 'Bệnh viện');
    await shot(tester, 'A04_admin_benh_vien');

    // ─── A05: Tab Bác sĩ (danh sách + duyệt) ────────────────────────────────
    await tapBottomNavLabel(tester, 'Bác sĩ');
    await shot(tester, 'A05_admin_bac_si');

    // ─── A06: Tab Nội dung (bài viết) ───────────────────────────────────────
    await tapBottomNavLabel(tester, 'Nội dung');
    await shot(tester, 'A06_admin_noi_dung');

    // ─── A07: Tab Cài đặt hệ thống ──────────────────────────────────────────
    await tapBottomNavLabel(tester, 'Cài đặt');
    await shot(tester, 'A07_admin_cai_dat');

    // ─── A08: KYC duyệt bác sĩ ──────────────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 2000);
    await nav(tester, '/admin/kyc-approvals');
    await shot(tester, 'A08_admin_kyc_duyet');

    // ─── A09: Quản lý lịch hẹn ──────────────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 1500);
    await nav(tester, '/admin/appointments');
    await shot(tester, 'A09_admin_lich_hen');

    // ─── A10: Tất cả bệnh nhân ──────────────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 1500);
    await nav(tester, '/admin/patients');
    await shot(tester, 'A10_admin_benh_nhan');

    // ─── A11: Gửi thông báo broadcast ───────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 1500);
    await nav(tester, '/admin/broadcast');
    await shot(tester, 'A11_admin_broadcast');

    // ─── A12: Duyệt đánh giá ────────────────────────────────────────────────
    AppRouter.router.go('/admin/dashboard');
    await settle(tester, ms: 1500);
    await nav(tester, '/admin/reviews');
    await shot(tester, 'A12_admin_danh_gia');

    // ignore: avoid_print
    print('XONG - Toàn bộ màn hình admin đã chụp xong');
  }, timeout: Timeout.none);
}

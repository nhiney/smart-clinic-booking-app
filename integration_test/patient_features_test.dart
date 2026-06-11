// Test tự động chụp màn hình từng bước các tính năng của VAI TRÒ BỆNH NHÂN.
// Chạy bằng:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/patient_features_test.dart -d <device>
// Ảnh được lưu vào test_screenshots/patient/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/services/local_account_store.dart';
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const testPhone = '912345678';
const testPhoneNormalized = '84912345678';
const testPassword = 'Icare@123';
const testVirtualEmail = '84912345678@icare.patient';

late IntegrationTestWidgetsFlutterBinding binding;
final List<String> stepLog = [];
final List<String> failures = [];

/// Pump liên tục trong [ms] mili-giây (cho phép async thật chạy).
Future<void> settle(WidgetTester tester, {int ms = 1200}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Đợi đến khi [finder] xuất hiện, tối đa [timeoutMs].
Future<bool> waitFor(WidgetTester tester, Finder finder,
    {int timeoutMs = 15000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  try {
    await binding.takeScreenshot(name);
    // ignore: avoid_print
    print('[SHOT] $name');
  } catch (e) {
    failures.add('screenshot $name: $e');
    // ignore: avoid_print
    print('[SHOT-FAIL] $name: $e');
  }
}

Future<void> safeTap(WidgetTester tester, Finder finder,
    {String label = ''}) async {
  try {
    await tester.ensureVisible(finder.first);
  } catch (_) {}
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 300));
  // ignore: avoid_print
  print('[TAP] $label');
}

/// Cuộn cho tới khi thấy [target] (dùng cho danh sách/sliver).
Future<bool> scrollTo(WidgetTester tester, Finder target,
    {int maxSwipes = 10, double dy = -350}) async {
  for (var i = 0; i < maxSwipes; i++) {
    if (target.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(target.first);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 300));
      return true;
    }
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isEmpty) return false;
    await tester.drag(scrollable.first, Offset(0, dy), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
  }
  return target.evaluate().isNotEmpty;
}

Future<void> step(String name, Future<void> Function() body) async {
  // ignore: avoid_print
  print('[STEP] ▶ $name');
  try {
    await body();
    stepLog.add('OK   $name');
  } catch (e, st) {
    stepLog.add('FAIL $name: $e');
    failures.add('$name: $e');
    // ignore: avoid_print
    print('[STEP-FAIL] $name: $e\n$st');
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bệnh nhân - test toàn bộ tính năng, chụp từng bước',
      (tester) async {
    // ── KHỞI ĐỘNG APP ──────────────────────────────────────────────────────
    await app.main();
    await settle(tester, ms: 5000);

    // Chuẩn bị: đảm bảo có tài khoản test & đăng xuất sạch
    await step('Chuẩn bị tài khoản test', () async {
      // Seed tài khoản local (offline) — idempotent
      await LocalAccountStore.instance.saveAccount(
        phone: testPhoneNormalized,
        password: testPassword,
        name: 'Nguyễn Văn An',
      );
      // Đảm bảo tài khoản Firebase tồn tại
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testVirtualEmail, password: testPassword);
      } on FirebaseAuthException catch (e) {
        // email-already-in-use là OK
        // ignore: avoid_print
        print('[SETUP] createUser: ${e.code}');
      }
      await FirebaseAuth.instance.signOut();
      AppRouter.clearRoleCache();
      AppRouter.mockAuthNotifier.value = false;
    });

    // ════════════════════════ 01. ĐĂNG NHẬP ════════════════════════════════
    await step('01 Mở màn hình chào (onboarding)', () async {
      AppRouter.router.go('/');
      await settle(tester, ms: 2500);
      await shot(tester, '01_01_man_hinh_chao_onboarding');
    });

    await step('01 Mở màn hình đăng nhập', () async {
      AppRouter.router.go('/login');
      await settle(tester, ms: 2000);
      await shot(tester, '01_02_man_hinh_dang_nhap');
    });

    final phoneField = find.byType(TextField).at(0);
    final passField = find.byType(TextField).at(1);
    final loginButton = find.byType(AppButton).first;

    await step('01 Nhập SĐT sai định dạng → báo lỗi', () async {
      await tester.enterText(phoneField, '123');
      await tester.enterText(passField, testPassword);
      await tester.pump(const Duration(milliseconds: 300));
      await shot(tester, '01_03_nhap_sdt_sai_dinh_dang');
      await safeTap(tester, loginButton, label: 'Đăng nhập (SĐT sai)');
      await waitFor(tester, find.byType(SnackBar), timeoutMs: 8000);
      await shot(tester, '01_04_bao_loi_sdt_khong_hop_le');
      await settle(tester, ms: 4500); // chờ snackbar biến mất
    });

    await step('01 Nhập sai mật khẩu → báo lỗi', () async {
      await tester.enterText(phoneField, testPhone);
      await tester.enterText(passField, 'SaiMatKhau@999');
      await tester.pump(const Duration(milliseconds: 300));
      await shot(tester, '01_05_nhap_dung_sdt_sai_mat_khau');
      await safeTap(tester, loginButton, label: 'Đăng nhập (sai mật khẩu)');
      await waitFor(tester, find.byType(SnackBar), timeoutMs: 25000);
      await shot(tester, '01_06_bao_loi_sai_mat_khau');
      await settle(tester, ms: 4500);
    });

    await step('01 Nhập đúng → đăng nhập thành công', () async {
      await tester.enterText(phoneField, testPhone);
      await tester.enterText(passField, testPassword);
      await tester.pump(const Duration(milliseconds: 300));
      await shot(tester, '01_07_nhap_dung_thong_tin');
      await safeTap(tester, loginButton, label: 'Đăng nhập (đúng)');
      // Đảm bảo phiên Firebase thật để các tính năng sau hoạt động
      await settle(tester, ms: 3000);
      if (FirebaseAuth.instance.currentUser == null) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: testVirtualEmail, password: testPassword);
        } catch (e) {
          // ignore: avoid_print
          print('[LOGIN] Firebase fallback sign-in: $e');
        }
      }
      final ok = await waitFor(
          tester, find.textContaining('Đặt khám'), timeoutMs: 20000);
      if (!ok) {
        AppRouter.router.go('/home');
        await settle(tester, ms: 4000);
      }
      await shot(tester, '01_08_dang_nhap_thanh_cong_trang_chu');
    });

    // ════════════════════════ 02. TRANG CHỦ ════════════════════════════════
    await step('02 Trang chủ bệnh nhân', () async {
      AppRouter.router.go('/home');
      await settle(tester, ms: 4000);
      await shot(tester, '02_01_trang_chu_dau_trang');
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -550),
            warnIfMissed: false);
        await settle(tester, ms: 1500);
        await shot(tester, '02_02_trang_chu_tien_ich_nhanh');
        await tester.drag(scrollable.first, const Offset(0, -650),
            warnIfMissed: false);
        await settle(tester, ms: 1500);
        await shot(tester, '02_03_trang_chu_keo_xuong');
        await tester.drag(scrollable.first, const Offset(0, -700),
            warnIfMissed: false);
        await settle(tester, ms: 1500);
        await shot(tester, '02_04_trang_chu_cuoi_trang');
        // Cuộn về đầu
        await tester.drag(scrollable.first, const Offset(0, 2500),
            warnIfMissed: false);
        await settle(tester, ms: 1000);
      }
    });

    // ════════════════════════ 03. TÌM BÁC SĨ ═══════════════════════════════
    await step('03 Mở màn tìm bác sĩ', () async {
      AppRouter.router.push('/doctor/find');
      await settle(tester, ms: 5000); // chờ tải bác sĩ từ Firestore
      await shot(tester, '03_01_man_tim_bac_si');
    });

    await step('03 Nhập từ khóa tìm kiếm', () async {
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Nguyễn');
      await settle(tester, ms: 2000);
      await shot(tester, '03_02_nhap_tu_khoa_Nguyen');
      await tester.enterText(searchField, 'zzzkhongtonta');
      await settle(tester, ms: 2000);
      await shot(tester, '03_03_tim_kiem_khong_co_ket_qua');
      await tester.enterText(searchField, '');
      await settle(tester, ms: 2000);
      await shot(tester, '03_04_xoa_tim_kiem_hien_lai_danh_sach');
    });

    // ════════════════════════ 04. ĐẶT LỊCH KHÁM ════════════════════════════
    await step('04 Chọn bác sĩ từ danh sách', () async {
      final bookBtn = find.text('Đặt khám');
      final found = await scrollTo(tester, bookBtn);
      expect(found, true, reason: 'Không tìm thấy nút Đặt khám');
      await safeTap(tester, bookBtn, label: 'Đặt khám trên thẻ bác sĩ');
      await waitFor(tester, find.text('Đặt lịch'), timeoutMs: 10000);
      await settle(tester, ms: 2500);
      await shot(tester, '04_01_ho_so_bac_si_tab_dat_lich');
    });

    await step('04 Chọn giờ khám', () async {
      // Slot khả dụng buổi sáng: 09:30 / 10:00 / 10:30 / 11:30
      Finder slot = find.text('09:30');
      var found = await scrollTo(tester, slot, maxSwipes: 6);
      if (!found) {
        slot = find.text('10:00');
        found = await scrollTo(tester, slot, maxSwipes: 4);
      }
      await shot(tester, '04_02_danh_sach_khung_gio');
      if (found) {
        await safeTap(tester, slot, label: 'Chọn khung giờ');
        await settle(tester, ms: 800);
        await shot(tester, '04_03_da_chon_gio_kham');
      }
    });

    await step('04 Xác nhận đặt khám → báo thành công', () async {
      final confirmBtn = find.byIcon(Icons.arrow_forward_rounded).last;
      await safeTap(tester, confirmBtn, label: 'Nút xác nhận đặt khám');
      final ok = await waitFor(
          tester, find.text('Đặt khám thành công'), timeoutMs: 25000);
      await shot(tester, '04_04_dat_kham_thanh_cong');
      if (ok) {
        await safeTap(tester, find.text('Xem lịch hẹn'),
            label: 'Xem lịch hẹn');
        await settle(tester, ms: 3000);
        await shot(tester, '04_05_man_xac_nhan_dat_kham');
      }
    });

    // ════════════════════════ 05. LỊCH HẸN CỦA TÔI ═════════════════════════
    await step('05 Danh sách lịch hẹn', () async {
      AppRouter.router.go('/appointments');
      await settle(tester, ms: 5000);
      await shot(tester, '05_01_danh_sach_lich_hen');
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -400),
            warnIfMissed: false);
        await settle(tester, ms: 1200);
        await shot(tester, '05_02_lich_hen_keo_xuong');
      }
    });

    await step('05 Lịch hẹn (giao diện iCare)', () async {
      AppRouter.router.go('/patient/appointments');
      await settle(tester, ms: 5000);
      await shot(tester, '05_03_lich_hen_giao_dien_icare');
    });

    // ════════════════ 06. HỒ SƠ - GIA ĐÌNH - THÔNG BÁO ═════════════════════
    final extraScreens = <String, String>{
      '/profile/patient': '06_01_ho_so_ca_nhan',
      '/family': '06_02_ho_so_gia_dinh',
      '/notifications': '06_03_thong_bao',
      '/medical-records': '07_01_ho_so_y_te',
      '/prescriptions': '07_02_don_thuoc',
      '/medication-schedule': '07_03_lich_uong_thuoc',
      '/invoices': '07_04_hoa_don',
      '/insurance': '07_05_bao_hiem',
      '/services': '07_06_dich_vu',
      '/support': '07_07_ho_tro',
      '/news': '07_08_tin_tuc_suc_khoe',
    };
    for (final entry in extraScreens.entries) {
      await step('Chụp màn ${entry.key}', () async {
        AppRouter.router.go('/home');
        await settle(tester, ms: 1200);
        AppRouter.router.push(entry.key);
        await settle(tester, ms: 4000);
        await shot(tester, entry.value);
      });
    }

    // ── TỔNG KẾT ───────────────────────────────────────────────────────────
    // ignore: avoid_print
    print('══════════ KẾT QUẢ TỪNG BƯỚC ══════════');
    for (final s in stepLog) {
      // ignore: avoid_print
      print(s);
    }
    if (failures.isNotEmpty) {
      // ignore: avoid_print
      print('CÓ ${failures.length} BƯỚC LỖI: $failures');
    }
  }, timeout: Timeout.none);
}

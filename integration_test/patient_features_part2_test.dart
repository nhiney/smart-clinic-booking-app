// PHẦN 2 — Bổ sung các tính năng còn thiếu của VAI TRÒ BỆNH NHÂN:
// đăng ký, điều khoản, OTP, quên/tạo mật khẩu, QR login, voice AI + popup đặt lịch,
// và loạt màn tính năng còn lại (cấp cứu, khám trực tuyến, kết quả XN, bản đồ...).
//
// Chạy:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/patient_features_part2_test.dart -d <device>

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/services/local_account_store.dart';
import 'package:smart_clinic_booking/shared/router/app_router.dart';
import 'package:smart_clinic_booking/features/identity/auth/presentation/screens/terms_screen.dart';
import 'package:smart_clinic_booking/features/support_services/ai/presentation/widgets/voice_booking_confirm_sheet.dart';
import 'package:smart_clinic_booking/features/support_services/ai/presentation/riverpod/assistant_state.dart';

const testPhone = '912345678';
const testPhoneNormalized = '84912345678';
const testPassword = 'Icare@123';
const testVirtualEmail = '84912345678@icare.patient';

late IntegrationTestWidgetsFlutterBinding binding;
final List<String> stepLog = [];
final List<String> failures = [];

Future<void> settle(WidgetTester tester, {int ms = 1200}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<bool> waitFor(WidgetTester tester, Finder finder,
    {int timeoutMs = 12000}) async {
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

/// Lấy 1 context đang hiển thị để push overlay/sheet.
BuildContext _liveContext(WidgetTester tester) {
  return tester.element(find.byType(Navigator).last);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bệnh nhân - PHẦN 2 - tính năng còn lại, chụp từng bước',
      (tester) async {
    await app.main();
    await settle(tester, ms: 5000);

    await step('Chuẩn bị: seed tài khoản', () async {
      await LocalAccountStore.instance.saveAccount(
        phone: testPhoneNormalized, password: testPassword, name: 'Nguyễn Văn An');
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testVirtualEmail, password: testPassword);
      } on FirebaseAuthException catch (_) {}
    });

    // ══════════════════ PHẦN A — CÁC MÀN XÁC THỰC (ĐĂNG XUẤT) ══════════════════
    await step('A Đăng xuất để xem các màn xác thực', () async {
      await FirebaseAuth.instance.signOut();
      AppRouter.clearRoleCache();
      AppRouter.mockAuthNotifier.value = false;
      await settle(tester, ms: 2000);
    });

    // ── ĐĂNG KÝ ──────────────────────────────────────────────────────────────
    await step('08 Mở màn đăng ký', () async {
      AppRouter.router.go('/sign-up');
      await settle(tester, ms: 2500);
      await shot(tester, '08_01_man_dang_ky');
    });

    await step('08 Nhập thông tin nhưng CHƯA tick điều khoản → báo lỗi', () async {
      final fields = find.byType(TextField);
      if (fields.evaluate().length >= 2) {
        await tester.enterText(fields.at(0), 'Nguyễn Văn An');
        await tester.enterText(fields.at(1), testPhone);
        await tester.pump(const Duration(milliseconds: 300));
      }
      await shot(tester, '08_02_dien_thong_tin_dang_ky');
      // Bấm Đăng ký khi chưa tick điều khoản
      final regBtn = find.byType(AppButton).first;
      await safeTap(tester, regBtn, label: 'Đăng ký (chưa tick điều khoản)');
      await waitFor(tester, find.byType(SnackBar), timeoutMs: 6000);
      await shot(tester, '08_03_bao_loi_chua_dong_y_dieu_khoan');
      await settle(tester, ms: 4000);
    });

    await step('08 Xem màn ĐIỀU KHOẢN sử dụng', () async {
      Navigator.of(_liveContext(tester), rootNavigator: true).push(
        MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
      );
      await settle(tester, ms: 2500);
      await shot(tester, '08_04_man_dieu_khoan_su_dung');
      // Cuộn xem thêm điều khoản
      final sc = find.byType(Scrollable);
      if (sc.evaluate().isNotEmpty) {
        await tester.drag(sc.first, const Offset(0, -500), warnIfMissed: false);
        await settle(tester, ms: 1200);
        await shot(tester, '08_05_dieu_khoan_keo_xuong');
      }
      Navigator.of(_liveContext(tester), rootNavigator: true).pop();
      await settle(tester, ms: 1500);
    });

    await step('08 Tick đồng ý điều khoản', () async {
      final cb = find.byType(Checkbox);
      if (cb.evaluate().isNotEmpty) {
        await safeTap(tester, cb, label: 'Tick điều khoản');
        await settle(tester, ms: 600);
        await shot(tester, '08_06_da_tick_dong_y_dieu_khoan');
      }
    });

    // ── OTP ──────────────────────────────────────────────────────────────────
    await step('08 Màn nhập mã OTP', () async {
      AppRouter.router.push('/verify-otp', extra: {
        'phone': '+84$testPhone',
        'name': 'Nguyễn Văn An',
      });
      await settle(tester, ms: 2500);
      await shot(tester, '08_07_man_nhap_ma_otp');
    });

    await step('08 Nhập mã OTP 6 số', () async {
      final boxes = find.byType(TextField);
      final n = boxes.evaluate().length;
      const code = '123456';
      for (var i = 0; i < 6 && i < n; i++) {
        await tester.enterText(boxes.at(i), code[i]);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await shot(tester, '08_08_da_nhap_ma_otp');
    });

    // ══════════════════ PHẦN B — MẬT KHẨU / QR / STAFF ════════════════════════
    await step('09 Màn quên mật khẩu', () async {
      AppRouter.router.go('/forgot-password');
      await settle(tester, ms: 2500);
      await shot(tester, '09_01_man_quen_mat_khau');
      final f = find.byType(TextField);
      if (f.evaluate().isNotEmpty) {
        await tester.enterText(f.first, testPhone);
        await tester.pump(const Duration(milliseconds: 300));
        await shot(tester, '09_02_nhap_sdt_quen_mat_khau');
      }
    });

    await step('09 Màn tạo mật khẩu mới', () async {
      AppRouter.router.go('/create-password', extra: {
        'phone': '+84$testPhone', 'name': 'Nguyễn Văn An',
      });
      await settle(tester, ms: 2500);
      await shot(tester, '09_03_man_tao_mat_khau');
      final f = find.byType(TextField);
      if (f.evaluate().length >= 2) {
        await tester.enterText(f.at(0), 'MatKhauMoi@123');
        await tester.enterText(f.at(1), 'MatKhauMoi@123');
        await tester.pump(const Duration(milliseconds: 300));
        await shot(tester, '09_04_da_nhap_mat_khau_moi');
      }
    });

    await step('10 Màn đăng nhập bằng QR (camera)', () async {
      AppRouter.router.go('/qr-login');
      await settle(tester, ms: 3000);
      await shot(tester, '10_01_dang_nhap_quet_ma_qr');
    });

    await step('10 Màn mã QR tài khoản', () async {
      AppRouter.router.go('/account-qr', extra: {
        'token': 'DEMO-TOKEN-123456', 'expiresAt': '2026-12-31T23:59:59Z',
      });
      await settle(tester, ms: 2500);
      await shot(tester, '10_02_ma_qr_tai_khoan');
    });

    await step('10 Màn đăng nhập nhân viên (staff)', () async {
      AppRouter.router.go('/staff-login');
      await settle(tester, ms: 2500);
      await shot(tester, '10_03_dang_nhap_nhan_vien');
    });

    // ══════════════════ PHẦN C — ĐĂNG NHẬP LẠI → MÀN TÍNH NĂNG ════════════════
    await step('Đăng nhập lại để xem các màn tính năng', () async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: testVirtualEmail, password: testPassword);
      } catch (e) {
        // ignore: avoid_print
        print('[LOGIN] $e');
      }
      AppRouter.mockAuthNotifier.value = true;
      AppRouter.clearRoleCache();
      await settle(tester, ms: 3000);
      AppRouter.router.go('/home');
      await settle(tester, ms: 3500);
    });

    // ── VOICE AI ─────────────────────────────────────────────────────────────
    await step('11 Màn trợ lý giọng nói (Voice AI)', () async {
      AppRouter.router.push('/ai/voice-assistant');
      await settle(tester, ms: 3500);
      await shot(tester, '11_01_man_voice_ai_tro_ly_giong_noi');
    });

    await step('11 Popup xác nhận đặt lịch bằng giọng nói', () async {
      // Hiển thị trực tiếp bottom sheet xác nhận (mô phỏng khi AI nhận diện ý định đặt lịch)
      showModalBottomSheet<void>(
        context: _liveContext(tester),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VoiceBookingConfirmSheet(
          data: const BookingIntentData(
            specialty: 'Tim mạch',
            date: 'Thứ 5, 12/06/2026',
            timeSlot: '09:30',
          ),
          onClose: () {},
        ),
      );
      await settle(tester, ms: 2500);
      await shot(tester, '11_02_popup_dat_lich_bang_giong_noi');
      // Đóng sheet
      try {
        Navigator.of(_liveContext(tester)).pop();
      } catch (_) {}
      await settle(tester, ms: 1200);
    });

    // ── CÁC MÀN TÍNH NĂNG CÒN LẠI ────────────────────────────────────────────
    final screens = <String, String>{
      '/consultation': '12_01_kham_truc_tuyen',
      '/sos': '12_02_cap_cuu_sos',
      '/lab-results': '12_03_ket_qua_xet_nghiem',
      '/medical-history': '12_04_lich_su_kham',
      '/medication': '12_05_quan_ly_thuoc',
      '/maps': '12_06_ban_do',
      '/hospitals': '12_07_danh_sach_benh_vien',
      '/transactions': '12_08_lich_su_giao_dich',
      '/payment': '12_09_thanh_toan',
      '/invoice-bill': '12_10_hoa_don_chi_tiet',
      '/health-library': '12_11_thu_vien_suc_khoe',
      '/pricing': '12_12_bang_gia_dich_vu',
      '/surveys': '12_13_khao_sat',
      '/contact': '12_14_lien_he',
      '/support/chatbot': '12_15_chatbot_ho_tro',
      '/support/faq': '12_16_cau_hoi_thuong_gap',
      '/support/tickets': '12_17_yeu_cau_ho_tro',
      '/notifications/settings': '12_18_cai_dat_nhac_nho',
      '/profile-detail': '12_19_chi_tiet_ho_so',
    };
    for (final e in screens.entries) {
      await step('Chụp màn ${e.key}', () async {
        AppRouter.router.go('/home');
        await settle(tester, ms: 1000);
        AppRouter.router.push(e.key);
        await settle(tester, ms: 3500);
        await shot(tester, e.value);
      });
    }

    // ── TỔNG KẾT ───────────────────────────────────────────────────────────
    // ignore: avoid_print
    print('══════════ KẾT QUẢ PHẦN 2 ══════════');
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

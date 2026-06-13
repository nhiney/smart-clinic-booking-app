// Demo VIDEO ĐẦY ĐỦ — vai trò BỆNH NHÂN: đăng ký + OTP + lưu QR + quét QR đăng
// nhập, và TẤT CẢ tính năng (không bỏ phần nào), thao tác chi tiết + cuộn xem
// hết nội dung, kèm phụ đề. Quay bằng simctl recordVideo.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/services/local_account_store.dart';
import 'package:smart_clinic_booking/shared/router/app_router.dart';
import 'package:smart_clinic_booking/features/identity/auth/presentation/screens/terms_screen.dart';

const testPhone = '912345678';
const testPhoneNormalized = '84912345678';
const testPassword = 'Icare@123';
const testVirtualEmail = '84912345678@icare.patient';

late IntegrationTestWidgetsFlutterBinding binding;
String uid = '';

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

Future<bool> waitFor(WidgetTester tester, Finder f, {int timeoutMs = 10000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 150));
    if (f.evaluate().isNotEmpty) return true;
  }
  return false;
}

Future<void> tap(WidgetTester tester, Finder f) async {
  try {
    await tester.ensureVisible(f.first);
  } catch (_) {}
  await tester.tap(f.first, warnIfMissed: false);
  await beat(tester, 400);
}

Future<void> typeIn(WidgetTester tester, int idx, String text) async {
  final f = find.byType(TextField);
  if (f.evaluate().length > idx) {
    await tester.enterText(f.at(idx), text);
    await beat(tester, 500);
  }
}

Future<void> scrollDown(WidgetTester tester, {double dy = -420, int hold = 2000}) async {
  final sc = find.byType(Scrollable);
  if (sc.evaluate().isNotEmpty) {
    await tester.drag(sc.first, Offset(0, dy), warnIfMissed: false);
    await beat(tester, hold);
  }
}

// Mở 1 màn: caption đặt SAU khi màn đã tải (caption khớp khung hình).
Future<void> feature(WidgetTester tester, String caption, String route,
    {int hold = 3400, bool scroll = false, bool scroll2 = false}) async {
  try {
    AppRouter.router.go('/home');
    await beat(tester, 700);
    AppRouter.router.push(route);
    await beat(tester, 1500);
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

  testWidgets('Bệnh nhân DEMO ĐẦY ĐỦ - đăng ký + QR + tất cả tính năng',
      (tester) async {
    await app.main();
    await beat(tester, 5000);

    // chuẩn bị tài khoản (cho phần đăng nhập lại + dữ liệu)
    try {
      await LocalAccountStore.instance.saveAccount(
          phone: testPhoneNormalized, password: testPassword, name: 'Nguyễn Văn An');
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: testVirtualEmail, password: testPassword);
      } on FirebaseAuthException catch (_) {}
      await FirebaseAuth.instance.signOut();
      AppRouter.clearRoleCache();
      AppRouter.mockAuthNotifier.value = false;
    } catch (_) {}

    // ignore: avoid_print
    print('[DEMO-READY]');
    await beat(tester, 2500);

    // ════════════ PHẦN 1 — ĐĂNG KÝ TÀI KHOẢN MỚI ════════════
    step('Màn chào mừng — ứng dụng ICare Health cho bệnh nhân');
    AppRouter.router.go('/');
    await beat(tester, 3000);

    step('Đăng ký tài khoản mới — nhập họ tên & số điện thoại');
    AppRouter.router.go('/sign-up');
    await beat(tester, 2400);
    await typeIn(tester, 0, 'Trần Thị Hương');
    await typeIn(tester, 1, '0987654321');
    await beat(tester, 2200);

    step('Đọc & đồng ý Điều khoản sử dụng dịch vụ');
    try {
      Navigator.of(tester.element(find.byType(Navigator).last),
              rootNavigator: true)
          .push(MaterialPageRoute<void>(builder: (_) => const TermsScreen()));
    } catch (_) {}
    await beat(tester, 2600);
    await scrollDown(tester, dy: -520, hold: 2200);
    try {
      Navigator.of(tester.element(find.byType(Navigator).last),
              rootNavigator: true)
          .pop();
    } catch (_) {}
    await beat(tester, 1500);
    final cb = find.byType(Checkbox);
    if (cb.evaluate().isNotEmpty) {
      step('Tick đồng ý điều khoản rồi nhấn Đăng ký');
      await tap(tester, cb);
      await beat(tester, 1800);
    }

    // OTP
    step('Nhập mã OTP gửi về điện thoại để xác thực');
    AppRouter.router.push('/verify-otp',
        extra: {'phone': '+84$testPhone', 'name': 'Trần Thị Hương'});
    await beat(tester, 2400);
    const code = '123456';
    final boxes = find.byType(TextField);
    final n = boxes.evaluate().length;
    for (var i = 0; i < 6 && i < n; i++) {
      await tester.enterText(boxes.at(i), code[i]);
      await beat(tester, 280);
    }
    await beat(tester, 2400);

    // Tạo mật khẩu
    step('Tạo mật khẩu cho tài khoản mới');
    AppRouter.router.go('/create-password',
        extra: {'phone': '+84$testPhone', 'name': 'Trần Thị Hương'});
    await beat(tester, 2200);
    await typeIn(tester, 0, 'MatKhau@2026');
    await typeIn(tester, 1, 'MatKhau@2026');
    await beat(tester, 2200);

    // Lưu QR
    step('Lưu mã QR tài khoản — để lần sau quét đăng nhập nhanh');
    AppRouter.router.go('/account-qr', extra: {
      'token': 'ICARE-QR-TOKEN-2468013579',
      'expiresAt': '2026-12-31T23:59:59Z',
    });
    await beat(tester, 4000);

    // Quét QR đăng nhập
    step('Lần sau: quét mã QR để đăng nhập không cần mật khẩu');
    AppRouter.router.go('/qr-login');
    await beat(tester, 3600);

    // ════════════ PHẦN 2 — ĐĂNG NHẬP ════════════
    step('Đăng nhập bằng số điện thoại & mật khẩu');
    AppRouter.router.go('/login');
    await beat(tester, 2200);
    await typeIn(tester, 0, testPhone);
    await typeIn(tester, 1, testPassword);
    await beat(tester, 800);
    try {
      await tester.tap(find.byType(AppButton).first, warnIfMissed: false);
      await beat(tester, 2500);
    } catch (_) {}
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: testVirtualEmail, password: testPassword);
      } catch (_) {}
    }
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await beat(tester, 3000);

    // ════════════ PHẦN 3 — TRANG CHỦ ════════════
    AppRouter.router.go('/home');
    await beat(tester, 2500);
    step('Trang chủ — chào mừng, đặt lịch nhanh, tiện ích');
    await beat(tester, 3200);
    step('Trang chủ — lưới chức năng đầy đủ');
    await scrollDown(tester, dy: -520, hold: 2600);
    await scrollDown(tester, dy: -560, hold: 2400);
    await scrollDown(tester, dy: -560, hold: 2200);
    await scrollDown(tester, dy: 2500, hold: 600);

    // ════════════ PHẦN 4 — ĐẶT LỊCH KHÁM ════════════
    step('Tìm bác sĩ theo tên, chuyên khoa, bệnh viện');
    AppRouter.router.go('/home');
    await beat(tester, 700);
    AppRouter.router.push('/doctor/find');
    await beat(tester, 4000);
    step('Gõ từ khoá để tìm bác sĩ');
    await typeIn(tester, 0, 'Nguyễn');
    await beat(tester, 2600);
    await typeIn(tester, 0, '');
    await beat(tester, 1500);
    // Mở hồ sơ bác sĩ + đặt lịch
    final book = find.text('Đặt khám');
    if (book.evaluate().isNotEmpty) {
      step('Mở hồ sơ bác sĩ & chọn khung giờ khám');
      await tap(tester, book);
      await beat(tester, 3500);
      Finder slot = find.text('09:30');
      if (slot.evaluate().isEmpty) slot = find.text('10:00');
      if (slot.evaluate().isEmpty) slot = find.text('10:30');
      if (slot.evaluate().isNotEmpty) {
        await tap(tester, slot);
        await beat(tester, 1500);
        step('Xác nhận đặt lịch khám');
        final confirm = find.byIcon(Icons.arrow_forward_rounded);
        if (confirm.evaluate().isNotEmpty) {
          await tester.tap(confirm.last, warnIfMissed: false);
          final ok = await waitFor(
              tester, find.text('Đặt khám thành công'), timeoutMs: 18000);
          await beat(tester, 1500);
          step(ok
              ? 'Đặt khám thành công — nhận mã QR lịch hẹn'
              : 'Màn xác nhận đặt khám');
          await beat(tester, 3500);
        }
      }
    }

    // Lịch hẹn của tôi (+ huỷ lịch)
    await feature(tester, 'Lịch hẹn của tôi — sắp tới, đã khám, đã huỷ',
        '/appointments', scroll: true);
    await feature(tester, 'Quản lý lịch hẹn (giao diện iCare)',
        '/patient/appointments', scroll: true);

    // ════════════ PHẦN 5 — HỒ SƠ CÁ NHÂN ════════════
    await feature(tester, 'Hồ sơ cá nhân của bạn', '/profile/patient', scroll: true);
    await feature(tester, 'Chi tiết hồ sơ — thông tin sức khoẻ', '/profile-detail', scroll: true);
    await feature(tester, 'Hồ sơ gia đình — quản lý người thân', '/family', scroll: true);

    // ════════════ PHẦN 6 — SỨC KHOẺ ════════════
    await feature(tester, 'Kết quả xét nghiệm — chỉ số & tóm tắt AI', '/lab-results', scroll: true, scroll2: true);
    await feature(tester, 'Lịch sử khám bệnh', '/medical-history', scroll: true);
    await feature(tester, 'Hồ sơ bệnh án điện tử', '/medical-records', scroll: true);
    await feature(tester, 'Quản lý thuốc đang dùng — nhắc giờ uống', '/medication', scroll: true);
    await feature(tester, 'Lịch uống thuốc', '/medication-schedule', scroll: true);
    await feature(tester, 'Đơn thuốc điện tử', '/prescriptions', scroll: true);

    // ════════════ PHẦN 7 — CƠ SỞ Y TẾ ════════════
    await feature(tester, 'Danh sách bệnh viện & phòng khám', '/hospitals', scroll: true);
    await feature(tester, 'Bản đồ cơ sở y tế gần bạn', '/maps');
    await feature(tester, 'Danh mục dịch vụ y tế', '/services', scroll: true);
    await feature(tester, 'Bảng giá dịch vụ', '/pricing', scroll: true);

    // ════════════ PHẦN 8 — TÀI CHÍNH ════════════
    await feature(tester, 'Thẻ bảo hiểm y tế (BHYT)', '/insurance');
    await feature(tester, 'Hoá đơn viện phí', '/invoices', scroll: true);
    await feature(tester, 'Chi tiết hoá đơn', '/invoice-bill', scroll: true);
    await feature(tester, 'Thanh toán viện phí — VNPay / MoMo / thẻ', '/payment', scroll: true);
    await feature(tester, 'Lịch sử giao dịch', '/transactions', scroll: true);

    // ════════════ PHẦN 9 — HỖ TRỢ & NỘI DUNG ════════════
    await feature(tester, 'Trung tâm hỗ trợ', '/support', scroll: true);
    await feature(tester, 'Chatbot hỗ trợ thông minh', '/support/chatbot');
    await feature(tester, 'Câu hỏi thường gặp (FAQ)', '/support/faq', scroll: true);
    await feature(tester, 'Gửi & theo dõi yêu cầu hỗ trợ', '/support/tickets', scroll: true);
    await feature(tester, 'Liên hệ phòng khám', '/contact', scroll: true);
    await feature(tester, 'Khảo sát mức độ hài lòng', '/surveys', scroll: true);
    await feature(tester, 'Thư viện sức khoẻ', '/health-library', scroll: true);
    await feature(tester, 'Tin tức sức khoẻ', '/news', scroll: true);

    // ════════════ PHẦN 10 — KHÁC ════════════
    await feature(tester, 'Khám trực tuyến — tư vấn từ xa', '/consultation', scroll: true);
    await feature(tester, 'Cấp cứu SOS — gọi khẩn cấp 115', '/sos');
    await feature(tester, 'Trợ lý giọng nói AI', '/ai/voice-assistant');
    if (uid.isNotEmpty) {
      await feature(tester, 'Đăng ký nhập viện', '/admission/registration/$uid', scroll: true);
      await feature(tester, 'Lịch sử nhập viện', '/admission/history/$uid', scroll: true);
    }
    await feature(tester, 'Trung tâm thông báo', '/notifications-center', scroll: true);
    await feature(tester, 'Thông báo', '/notifications', scroll: true);
    await feature(tester, 'Cài đặt thông báo & nhắc nhở', '/notifications/settings', scroll: true);
    await feature(tester, 'Mã QR tài khoản — xuất trình khi đến khám', '/account-qr');

    await beat(tester, 1500);
    // ignore: avoid_print
    print('XONG - DEMO hoàn tất');
    await beat(tester, 1000);
  }, timeout: Timeout.none);
}

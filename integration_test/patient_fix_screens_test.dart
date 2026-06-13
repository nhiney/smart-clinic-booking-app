// Chụp lại 4 màn hình đã sửa lỗi: health library, lịch hẹn, thông báo, yêu cầu hỗ trợ
// Chạy: flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/patient_fix_screens_test.dart -d <UDID>

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const testVirtualEmail = '84912345678@icare.patient';
const testPassword = 'Icare@123';

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

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chụp 4 màn hình đã sửa (patient)', (tester) async {
    await app.main();
    await settle(tester, ms: 5000);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testVirtualEmail, password: testPassword);
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN] $e');
    }

    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await settle(tester, ms: 6000);
    AppRouter.router.go('/home');
    await settle(tester, ms: 3000);

    // 1. Thư viện sức khoẻ
    AppRouter.router.push('/health-library');
    await settle(tester, ms: 5000);
    await shot(tester, '12_11_thu_vien_suc_khoe');

    // 2. Lịch hẹn (không còn overflow)
    AppRouter.router.go('/home');
    await settle(tester, ms: 1500);
    AppRouter.router.push('/appointments');
    await settle(tester, ms: 5000);
    await shot(tester, '13_01_lich_hen_co_du_lieu_cuon');

    // 3. Thông báo (có mock data)
    AppRouter.router.go('/home');
    await settle(tester, ms: 1500);
    AppRouter.router.push('/notifications');
    await settle(tester, ms: 4000);
    await shot(tester, '13_06_thong_bao_co_du_lieu_cuon');

    // 4. Yêu cầu hỗ trợ (không còn lỗi index)
    AppRouter.router.go('/home');
    await settle(tester, ms: 1500);
    AppRouter.router.push('/support/tickets');
    await settle(tester, ms: 5000);
    await shot(tester, '12_17_yeu_cau_ho_tro');

    // ignore: avoid_print
    print('XONG - 4 màn hình đã chụp');
  }, timeout: Timeout.none);
}

// Chụp lại nhanh các màn phụ thuộc composite index (dữ liệu đã seed sẵn ở phần 3).
// Đăng nhập bệnh nhân → AuthController nạp users/{uid} → currentUser → điều hướng.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const testPassword = 'Icare@123';
const testVirtualEmail = '84912345678@icare.patient';

late IntegrationTestWidgetsFlutterBinding binding;

Future<void> settle(WidgetTester tester, {int ms = 1200}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  // ignore: avoid_print
  print('[CAPTURE] $name');
  await settle(tester, ms: 2000);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chụp lại các màn index sau khi đã có index', (tester) async {
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
    // Chờ AuthController nạp profile (currentUser != null).
    await settle(tester, ms: 6000);
    AppRouter.router.go('/home');
    await settle(tester, ms: 3000);

    final screens = <String, String>{
      '/appointments': '13_01_lich_hen_co_du_lieu',
      '/medical-records': '13_03_ho_so_y_te_co_du_lieu',
      '/notifications': '13_06_thong_bao_co_du_lieu',
      '/invoices': '13_07_hoa_don_co_du_lieu',
      '/transactions': '13_08_giao_dich_co_du_lieu',
    };
    for (final e in screens.entries) {
      AppRouter.router.go('/home');
      await settle(tester, ms: 1200);
      AppRouter.router.push(e.key);
      await settle(tester, ms: 5000); // chờ query Firestore (index đã sẵn sàng)
      await shot(tester, e.value);
    }

    // ignore: avoid_print
    print('KẾT QUẢ PHẦN 3 (recapture xong)');
  }, timeout: Timeout.none);
}

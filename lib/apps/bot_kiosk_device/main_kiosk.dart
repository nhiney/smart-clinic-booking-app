import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/core/config/firebase_options.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/pages/slot_selection_page.dart';
import 'package:smart_clinic_booking/core/utils/idle_session_manager.dart';
import 'package:smart_clinic_booking/core/utils/network_listener.dart';
import 'package:smart_clinic_booking/core/utils/seed_kiosk_data.dart';

final networkListenerProvider = ChangeNotifierProvider((ref) => NetworkListener());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Tạm thời tạo dữ liệu mẫu để kiểm tra giao diện Kiosk
  await seedKioskData();

  runApp(
    const ProviderScope(
      child: ICareKioskBotApp(),
    ),
  );
}

class ICareKioskBotApp extends ConsumerStatefulWidget {
  const ICareKioskBotApp({super.key});

  @override
  ConsumerState<ICareKioskBotApp> createState() => _ICareKioskBotAppState();
}

class _ICareKioskBotAppState extends ConsumerState<ICareKioskBotApp> {
  late IdleSessionManager _idleManager;

  @override
  void initState() {
    super.initState();
    _idleManager = IdleSessionManager(
      timeout: const Duration(minutes: 5), // Tăng lên 5 phút cho thoải mái test
      onTimeout: () {
        debugPrint('[KIOSK] Session timeout - Resetting to Home');
        // Reset ứng dụng về trang chủ nếu cần
      },
    )..start();
  }

  @override
  void dispose() {
    _idleManager.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(networkListenerProvider).isOnline;

    return IdleDetector(
      manager: _idleManager,
      child: MaterialApp(
        title: 'ICare Smart Kiosk Bot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto', // Đảm bảo dùng font chuẩn
        ),
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              if (!isOnline)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    color: Colors.red.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: const SafeArea(
                      bottom: false,
                      child: Text(
                        'MẤT KẾT NỐI MẠNG - VUI LÒNG LIÊN HỆ LỄ TÂN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        home: const SlotSelectionPage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/core/config/firebase_options.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/pages/slot_selection_page.dart';
<<<<<<< HEAD
import 'package:smart_clinic_booking/core/utils/idle_session_manager.dart';
import 'package:smart_clinic_booking/core/utils/network_listener.dart';

// Provider cho Network Listener
final networkListenerProvider = ChangeNotifierProvider((ref) => NetworkListener());
=======
>>>>>>> 2e564c4 (chore(backend): install function dependencies version 2)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: ICareKioskBotApp(),
    ),
  );
}

<<<<<<< HEAD
class ICareKioskBotApp extends ConsumerWidget {
  const ICareKioskBotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Khởi tạo Idle Manager (Timeout 2 phút)
    final idleManager = IdleSessionManager(
      timeout: const Duration(minutes: 2),
      onTimeout: () {
        debugPrint('[KIOSK] Session timeout - Resetting to Home');
        // Quay về trang chủ (SlotSelectionPage)
        // navigatorKey.currentState?.popUntil((route) => route.isFirst);
      },
    )..start();

    final isOnline = ref.watch(networkListenerProvider).isOnline;

    return IdleDetector(
      manager: idleManager,
      child: MaterialApp(
        title: 'ICare Smart Kiosk Bot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              // Banner cảnh báo mất mạng
              if (!isOnline)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: const SafeArea(
                      bottom: false,
                      child: Text(
                        'MẤT KẾT NỐI MẠNG - VUI LÒNG LIÊN HỆ LỄ TÂN',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        home: const SlotSelectionPage(),
      ),
=======
class ICareKioskBotApp extends StatelessWidget {
  const ICareKioskBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICare Smart Kiosk Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SlotSelectionPage(),
>>>>>>> 2e564c4 (chore(backend): install function dependencies version 2)
    );
  }
}

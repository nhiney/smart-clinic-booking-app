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

class ICareKioskBotApp extends ConsumerWidget {
  const ICareKioskBotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idleManager = IdleSessionManager(
      timeout: const Duration(minutes: 2),
      onTimeout: () {
        debugPrint('[KIOSK] Session timeout');
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
              if (!isOnline)
                Positioned(
                  top: 0, left: 0, right: 0,
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
    );
  }
}

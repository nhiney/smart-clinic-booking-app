import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/core/config/firebase_options.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/presentation/pages/qr_checkin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: QRCheckInKioskApp(),
    ),
  );
}

class QRCheckInKioskApp extends StatelessWidget {
  const QRCheckInKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICare QR Check-in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const QRCheckInPage(),
    );
  }
}

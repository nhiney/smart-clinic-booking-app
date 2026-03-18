import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

// Doctor
import 'features/doctor/data/datasources/doctor_remote_datasource.dart';
import 'features/doctor/data/repositories/doctor_repository_impl.dart';
import 'features/doctor/presentation/controllers/doctor_controller.dart';

// Appointment
import 'features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/appointment/presentation/controllers/appointment_controller.dart';

// Medical Record
import 'features/medical_record/data/datasources/medical_record_remote_datasource.dart';
import 'features/medical_record/data/repositories/medical_record_repository_impl.dart';
import 'features/medical_record/presentation/controllers/medical_record_controller.dart';

// Medication
import 'features/medication/data/datasources/medication_remote_datasource.dart';
import 'features/medication/data/repositories/medication_repository_impl.dart';
import 'features/medication/presentation/controllers/medication_controller.dart';

// Profile
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

// Maps
import 'features/maps/data/datasources/maps_remote_datasource.dart';
import 'features/maps/data/repositories/maps_repository_impl.dart';
import 'features/maps/presentation/controllers/maps_controller.dart';

// Notification
import 'features/notification/data/datasources/notification_remote_datasource.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';

// Screens
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/home_screen.dart';
import 'features/doctor/presentation/screens/doctor_list_screen.dart';
import 'features/appointment/presentation/screens/appointment_history_screen.dart';
import 'features/medical_record/presentation/screens/medical_record_list_screen.dart';
import 'features/medication/presentation/screens/medication_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/maps/presentation/screens/clinic_map_screen.dart';
import 'features/notification/presentation/screens/notification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Data sources
  final authDatasource = AuthRemoteDatasource();
  final doctorDatasource = DoctorRemoteDatasource();
  final appointmentDatasource = AppointmentRemoteDatasource();
  final medicalRecordDatasource = MedicalRecordRemoteDatasource();
  final medicationDatasource = MedicationRemoteDatasource();
  final profileDatasource = ProfileRemoteDatasource();
  final mapsDatasource = MapsRemoteDatasource();
  final notificationDatasource = NotificationRemoteDatasource();

  // Repositories
  final authRepository = AuthRepositoryImpl(authDatasource);
  final doctorRepository = DoctorRepositoryImpl(doctorDatasource);
  final appointmentRepository = AppointmentRepositoryImpl(appointmentDatasource);
  final medicalRecordRepository = MedicalRecordRepositoryImpl(medicalRecordDatasource);
  final medicationRepository = MedicationRepositoryImpl(medicationDatasource);
  final profileRepository = ProfileRepositoryImpl(profileDatasource);
  final mapsRepository = MapsRepositoryImpl(mapsDatasource);
  final notificationRepository = NotificationRepositoryImpl(notificationDatasource);

  // Seed sample data (non-blocking, don't prevent app from starting)
  doctorDatasource.seedDoctors().catchError((e) {
    debugPrint('Seed doctors error: $e');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorController(repository: doctorRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentController(repository: appointmentRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicalRecordController(repository: medicalRecordRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicationController(repository: medicationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(repository: profileRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MapsController(repository: mapsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationController(repository: notificationRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Clinic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/doctors': (_) => const DoctorListScreen(),
        '/appointments': (_) => const AppointmentHistoryScreen(),
        '/medical-records': (_) => const MedicalRecordListScreen(),
        '/medication': (_) => const MedicationScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/maps': (_) => const ClinicMapScreen(),
        '/notifications': (_) => const NotificationScreen(),
      },
    );
  }
}

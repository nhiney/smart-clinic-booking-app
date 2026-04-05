import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'config/dependency_injection/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/app_config_service.dart';
import 'features/auth/presentation/bloc/sign_up_bloc.dart';

// Auth
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/verify_phone_usecase.dart';
import 'features/auth/domain/usecases/signin_with_phone_usecase.dart';
import 'features/auth/domain/usecases/create_password_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

// Doctor
import 'features/doctor/domain/repositories/doctor_repository.dart';
import 'features/doctor/data/datasources/doctor_remote_datasource.dart';
import 'features/doctor/presentation/controllers/doctor_controller.dart';

// Appointment
import 'features/appointment/domain/repositories/appointment_repository.dart';
import 'features/appointment/presentation/controllers/appointment_controller.dart';

// Medical Record
import 'features/medical_record/domain/repositories/medical_record_repository.dart';
import 'features/medical_record/presentation/controllers/medical_record_controller.dart';

// Medication
import 'features/medication/domain/repositories/medication_repository.dart';
import 'features/medication/presentation/controllers/medication_controller.dart';

// Profile
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

// Maps
import 'features/maps/domain/repositories/maps_repository.dart';
import 'features/maps/presentation/controllers/maps_controller.dart';

// Notification
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';

// Screens
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/bloc/home_bloc_handler.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/usecases/get_health_summary_usecase.dart';
import 'features/home/domain/usecases/medication_usecases.dart';
import 'features/home/domain/usecases/get_health_news_usecase.dart';
import 'features/doctor/presentation/screens/doctor_list_screen.dart';
import 'features/appointment/presentation/screens/appointment_history_screen.dart';
import 'features/medical_record/presentation/screens/medical_record_list_screen.dart';
import 'features/medication/presentation/screens/medication_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/maps/presentation/screens/clinic_map_screen.dart';
import 'features/notification/presentation/screens/notification_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/appointment/domain/usecases/get_appointments_usecase.dart';
import 'features/doctor/domain/usecases/get_doctors_usecase.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    debugPrint('[DIAGNOSTIC] Khởi tạo Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final options = DefaultFirebaseOptions.currentPlatform;
    debugPrint('[DIAGNOSTIC] Project ID: ${options.projectId}');
    debugPrint('[DIAGNOSTIC] API Key: ${options.apiKey.substring(0, 5)}***');

    // Network Check for gRPC (Firestore)
    try {
      final googleDns = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 5));
      debugPrint('[DIAGNOSTIC] Kết nối Internet (8.8.8.8:53): THÀNH CÔNG');
      await googleDns.close();
      
      // Check if firestore.googleapis.com is reachable (gRPC Port 443)
      final firestoreHost = await Socket.connect('firestore.googleapis.com', 443, timeout: const Duration(seconds: 5));
      debugPrint('[DIAGNOSTIC] Kết nối gRPC (firestore.googleapis.com:443): THÀNH CÔNG');
      await firestoreHost.close();
    } catch (e) {
      debugPrint('[DIAGNOSTIC] LỖI KẾT NỐI MẠNG: $e');
    }

    // Disable Persistence on Emulators to fix 'unavailable' errors on MacOS/iOS simulators
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Dependency Injection
  await configureDependencies();

  // Initialize Dynamic Configuration (Firestore)
  await getIt<AppConfigService>().initialize();

  // Seed sample data (non-blocking, don't prevent app from starting)
  getIt<DoctorRemoteDatasource>().seedDoctors().catchError((e) {
    debugPrint('Seed doctors error: $e');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            loginUseCase: getIt<LoginUseCase>(),
            registerUseCase: getIt<RegisterUseCase>(),
            verifyPhoneUseCase: getIt<VerifyPhoneUseCase>(),
            signInWithPhoneUseCase: getIt<SignInWithPhoneUseCase>(),
            createPasswordUseCase: getIt<CreatePasswordUseCase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorController(repository: getIt<DoctorRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentController(repository: getIt<AppointmentRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicalRecordController(repository: getIt<MedicalRecordRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicationController(repository: getIt<MedicationRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(repository: getIt<ProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MapsController(repository: getIt<MapsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationController(repository: getIt<NotificationRepository>()),
        ),
        BlocProvider<HomeBlocHandler>(
          create: (_) {
            final homeRepo = HomeRepositoryImpl(HomeRemoteDatasourceImpl());
            return HomeBlocHandler(
              getHealthSummary: GetHealthSummaryUseCase(homeRepo),
              getMedicationReminders: GetMedicationRemindersUseCase(homeRepo),
              markMedicationTaken: MarkMedicationTakenUseCase(homeRepo),
              getHealthNews: GetHealthNewsUseCase(homeRepo),
              getAppointments: getIt<GetAppointmentsUseCase>(),
              getDoctors: getIt<GetDoctorsUseCase>(),
            );
          },
        ),
        BlocProvider<SignUpBloc>(
          create: (_) => SignUpBloc(),
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
    return MaterialApp.router(
      title: 'ICare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}

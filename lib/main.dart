import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'core/localization/language_service.dart';
import 'core/localization/language_controller.dart';
import 'core/localization/app_language.dart';

import 'firebase_options.dart';
import 'core/theme/theme/app_theme.dart';
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

// Medication
import 'features/medication/domain/repositories/medication_repository.dart';
import 'features/medication/presentation/controllers/medication_controller.dart';

// Profile
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

// Maps
import 'features/maps/domain/repositories/maps_repository.dart';

// Notification
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';

// Screens
import 'features/appointment/domain/usecases/get_appointments_usecase.dart';
import 'features/doctor/domain/usecases/get_doctors_usecase.dart';

// Home
import 'features/home/presentation/bloc/home_bloc_handler.dart';
import 'features/home/data/datasources/home_remote_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/usecases/get_health_summary_usecase.dart';
import 'features/home/domain/usecases/medication_usecases.dart';
import 'features/home/domain/usecases/get_health_news_usecase.dart';


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

  // Initialize Localization
  await LanguageService.init();

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
          create: (_) => MedicationController(repository: getIt<MedicationRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(repository: getIt<ProfileRepository>()),
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
          create: (context) => SignUpBloc(authController: context.read<AuthController>()),
        ),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageControllerProvider);

    return MaterialApp.router(
      title: 'ICare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Change to system if you want automatic dark mode
      routerConfig: appRouter,
      locale: language.locale,
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

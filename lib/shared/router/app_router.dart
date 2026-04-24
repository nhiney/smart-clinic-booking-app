import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_clinic_booking/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/staff_login_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/patient_home_screen.dart';
import 'package:smart_clinic_booking/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/screens/doctor_home_screen.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/screens/doctor_search_screen.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/screens/doctor_detail_screen.dart';
import 'package:smart_clinic_booking/features/doctor/domain/entities/doctor_entity.dart';
import 'package:smart_clinic_booking/features/admission/presentation/screens/admission_registration_screen.dart';
import 'package:smart_clinic_booking/features/admission/presentation/screens/admission_history_screen.dart';
import 'package:smart_clinic_booking/features/notification/presentation/screens/notification_screen.dart';
import 'package:smart_clinic_booking/features/notification/presentation/screens/reminder_settings_screen.dart';
import 'package:smart_clinic_booking/features/ai/presentation/screens/voice_assistant_screen.dart';
import 'package:smart_clinic_booking/features/support/presentation/screens/support_dashboard_screen.dart';
import 'package:smart_clinic_booking/features/support/presentation/screens/chatbot_screen.dart';
import 'package:smart_clinic_booking/features/support/presentation/screens/faq_screen.dart';
import 'package:smart_clinic_booking/features/support/presentation/screens/ticket_list_screen.dart';
import 'package:smart_clinic_booking/features/support/presentation/screens/ticket_chat_screen.dart';
import 'package:smart_clinic_booking/features/content/presentation/screens/news_screen.dart';
import 'package:smart_clinic_booking/features/content/presentation/screens/content_screens.dart';
import 'package:smart_clinic_booking/features/maps/presentation/screens/hospital_map_screen.dart';
import 'package:smart_clinic_booking/features/maps/presentation/screens/hospital_detail_screen.dart';
import 'package:smart_clinic_booking/features/maps/domain/entities/hospital_entity.dart';
import 'package:smart_clinic_booking/features/review/presentation/screens/review_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/create_password_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/account_qr_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/qr_login_scanner_screen.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';
import 'package:smart_clinic_booking/features/booking/presentation/screens/booking_screen.dart';
import 'package:smart_clinic_booking/features/checkin/presentation/screens/checkin_screen.dart';
import 'package:smart_clinic_booking/features/checkin/presentation/screens/appointment_qr_screen.dart';
import 'package:smart_clinic_booking/features/booking/domain/entities/booking_entity.dart';

import 'package:smart_clinic_booking/features/payment/presentation/screens/payment_screen.dart';
import 'package:smart_clinic_booking/features/payment/presentation/screens/payment_processing_screen.dart';
import 'package:smart_clinic_booking/features/payment/presentation/screens/transaction_screen.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/presentation/screens/medical_record_screen.dart';
import 'package:smart_clinic_booking/features/profile/presentation/screens/patient_profile_screen.dart';
import 'package:smart_clinic_booking/features/invoice/presentation/screens/invoice_screen.dart';
import 'package:smart_clinic_booking/features/appointment/presentation/screens/appointment_history_screen.dart';
import 'package:smart_clinic_booking/features/medical_record/presentation/screens/prescription_screen.dart';
import 'package:smart_clinic_booking/features/home/presentation/screens/services_screen.dart';
import 'package:smart_clinic_booking/features/medication/presentation/screens/medication_screen.dart';
import 'package:smart_clinic_booking/features/content/presentation/screens/health_library_screen.dart';
import 'package:smart_clinic_booking/features/review/presentation/screens/doctor_review_screen.dart';
import 'package:smart_clinic_booking/shared/widgets/under_development_screen.dart';

import 'package:smart_clinic_booking/shared/screens/status_screens.dart';

// No longer need placeholders as we implemented the real screens
class KycUploadScreen extends StatelessWidget {
  const KycUploadScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("KYC Upload Screen (Secure)")));
}

/// Custom notifier to bridge FirebaseAuth streams into GoRouter's refresh Listenable.
class GoRouterRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Centralized Router using GoRouter to enforce RBAC, ABAC, and Onboarding validation.
class AppRouter {
  
  static Stream<User?> get authStateChanges => FirebaseAuth.instance.idTokenChanges();
  
  /// Global notifier for mock login sessions (Debug only)
  static final ValueNotifier<bool> mockAuthNotifier = ValueNotifier(false);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([
        GoRouterRefreshStream(authStateChanges.map((user) {
           debugPrint('[ROUTER] Auth State Stream Fired: ${user?.uid ?? "NULL"}');
           return user;
        })),
        mockAuthNotifier,
    ]),
    redirect: (BuildContext context, GoRouterState state) async {
      final user = FirebaseAuth.instance.currentUser;
      final bool isMockAuthenticated = mockAuthNotifier.value;
      final path = state.uri.path;
      
      debugPrint('[ROUTER] Evaluating Redirect: $path, User: ${user?.uid ?? "NULL"}, MockAuth: $isMockAuthenticated');
      
      final bool isPublicRoute = path == '/' || 
                                path == '/login' || 
                                path == '/staff-login' ||
                                path == '/sign-up' ||
                                path == '/register' ||
                                path == '/verify-otp' ||
                                path == '/create-password' ||
                                path == '/qr-login' ||
                                path == '/account-qr';

      // 1. Unauthenticated Block
      if (user == null && !isMockAuthenticated) {
        if (isPublicRoute) return null;
        debugPrint('[ROUTER] Kicking unauthenticated user from $path to /login');
        return '/login';
      }

      if (user != null) {
        debugPrint('[ROUTER] Real User: ${user.uid}, Path: $path');
      } else {
        debugPrint('[ROUTER] Mock User Authenticated, Path: $path');
      }

      // REQUIREMENT: Role-based navigation
      String role = 'patient';
      Map<String, dynamic> claims = {};
      
      if (user != null) {
        final idTokenResult = await user.getIdTokenResult(); 
        claims = idTokenResult.claims ?? {};
        role = claims['role'] as String? ?? 'unverified';
        
        // Special case for seed accounts or just-signed-in users
        if (role == 'unverified') {
          if (user.email == 'admin@icare.com') {
            role = 'super_admin';
          } else if (user.email == 'annv.choray@icare.com') {
            role = 'doctor';
          }
        }
      } 
      
      debugPrint('[ROUTER] Current Role: $role');

      // 2. Pending KYC Approval Flow (Real Users only)
      if (user != null) {
        final status = claims['status'] as String? ?? 'active';
        if (status == 'pending') {
          if (path != '/pending-approval' && path != '/kyc_upload') {
            return '/pending-approval';
          }
          return null;
        }
      }

      // 3. User is Active but trying to view Onboarding / Login / Pending screens
      final bool isRegistrationFlow = path == '/register' ||
                                     path == '/sign-up' ||
                                     path == '/verify-otp' || 
                                     path == '/create-password' || 
                                     path == '/account-qr';

      if ((isPublicRoute || path == '/pending-approval') && !isRegistrationFlow && path != '/' && path != '/qr-login') {
         debugPrint('[ROUTER] Redirecting authenticated user away from public route to home/dashboard');
         if (role == 'doctor') return '/doctor/dashboard';
         if (role == 'admin' || role == 'super_admin' || role == 'hospital_manager') return '/admin/dashboard';
         return '/home'; 
      }

      // 4. Registration Flow Guard
      // If we are in registration flow but user is ALREADY fully registered (has role), 
      // maybe we should move them to home? 
      // BUT for now we allow them to finish the flow (e.g. creating password)
      
      // 5. Strict Role-Based ACL checks
      if (path.startsWith('/admin') && role != 'super_admin' && role != 'admin' && role != 'hospital_manager') {
        return '/forbidden';
      }
      if (path.startsWith('/doctor') && role != 'doctor') {
        // Allow patients to search and see doctor details
        if (path == '/doctor/search' || path.startsWith('/doctor/detail/')) {
          return null;
        }
        return '/forbidden';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/staff-login',
        builder: (context, state) => const StaffLoginScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            phoneNumber: extras['phone'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/create-password',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return CreatePasswordScreen(
            phoneNumber: extras['phone'] as String? ?? '',
            name: extras['name'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/qr-login',
        builder: (context, state) => const QrLoginScannerScreen(),
      ),
      GoRoute(
        path: '/account-qr',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return AccountQrScreen(
            token: extras['token'] as String? ?? '',
            expiresAt: extras['expiresAt'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const PatientHomeScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/notifications/settings',
        builder: (context, state) => const ReminderSettingsScreen(),
      ),
      GoRoute(
        path: '/admission/registration/:patientId',
        builder: (context, state) => AdmissionRegistrationScreen(
          patientId: state.pathParameters['patientId']!,
        ),
      ),
      GoRoute(
        path: '/admission/history/:patientId',
        builder: (context, state) => AdmissionHistoryScreen(
          patientId: state.pathParameters['patientId']!,
        ),
      ),
      GoRoute(
        path: '/kyc_upload',
        builder: (context, state) => const KycUploadScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorHomeScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/ai/voice-assistant',
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      // Support Module
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportDashboardScreen(),
      ),
      GoRoute(
        path: '/support/chatbot',
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/support/faq',
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: '/support/tickets',
        builder: (context, state) => const TicketListScreen(),
      ),
      GoRoute(
        path: '/support/tickets/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;
          final ticket = state.extra as SupportTicket?;
          return TicketChatScreen(ticketId: ticketId, ticket: ticket);
        },
      ),
      // Content Module
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: '/pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/surveys',
        builder: (context, state) => const SurveyScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactFormScreen(),
      ),
      GoRoute(
        path: '/maps',
        builder: (context, state) => const HospitalMapScreen(),
      ),
      GoRoute(
        path: '/hospital/detail/:id',
        builder: (context, state) {
          final hospitalId = state.pathParameters['id']!;
          final hospital = state.extra as HospitalEntity?;
          return HospitalDetailScreen(
            hospitalId: hospitalId,
            hospital: hospital,
          );
        },
      ),
      GoRoute(
        path: '/hospital/review/:hospitalId',
        builder: (context, state) {
          final hospitalId = state.pathParameters['hospitalId']!;
          final hospitalName = state.extra as String? ?? '';
          return ReviewScreen(hospitalId: hospitalId, hospitalName: hospitalName);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return PaymentScreen(
            amount: (extras['amount'] as num?)?.toDouble() ?? 0.0,
            description: extras['description'] as String? ?? 'Thanh toán dịch vụ',
          );
        },
      ),
      GoRoute(
        path: '/payment/processing',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return PaymentProcessingScreen(
            amount: (extras['amount'] as num?)?.toDouble() ?? 0.0,
            method: extras['method'] as PaymentMethod? ?? PaymentMethod.vnpay,
            description: extras['description'] as String? ?? '',
            userId: extras['userId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionScreen(),
      ),
      GoRoute(
        path: '/medical-records',
        builder: (context, state) => const MedicalRecordScreen(),
      ),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoiceScreen(),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentHistoryScreen(),
      ),
      GoRoute(
        path: '/prescriptions',
        builder: (context, state) => const PrescriptionScreen(),
      ),
      GoRoute(
        path: '/medication',
        builder: (context, state) => const MedicationScreen(),
      ),
      GoRoute(
        path: '/profile/patient',
        builder: (context, state) => const PatientProfileScreen(),
      ),
      GoRoute(
        path: '/doctor/search',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return DoctorSearchScreen(
            initialSearchText: extras['query'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/doctor/detail/:doctorId',
        builder: (context, state) {
          final doctorId = state.pathParameters['doctorId']!;
          final doctor = state.extra as DoctorEntity?;
          return DoctorDetailScreen(
            doctorId: doctorId,
            doctor: doctor,
          );
        },
      ),
      GoRoute(
        path: '/patient/create-appointment',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return BookingScreen(
            doctor: extras['doctor'] as DoctorEntity?,
          );
        },
      ),
      GoRoute(
        path: '/clinic/scanner',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return CheckInScreen(
            appointmentId: extras['appointmentId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/booking/qr',
        builder: (context, state) {
          final booking = state.extra as BookingEntity;
          return AppointmentQrScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/health-library',
        builder: (context, state) => const HealthLibraryScreen(),
      ),
      GoRoute(
        path: '/doctor/review/:doctorId',
        builder: (context, state) => DoctorReviewScreen(
          doctorId: state.pathParameters['doctorId']!,
          doctorName: state.extra as String? ?? 'Bác sĩ',
        ),
      ),
      GoRoute(
        path: '/under-development',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Tính năng';
          return UnderDevelopmentScreen(title: title);
        },
      ),
    ],
  );
}


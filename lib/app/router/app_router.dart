import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_clinic_booking/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/staff_login_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:smart_clinic_booking/features/home/presentation/screens/home_screen.dart';
import 'package:smart_clinic_booking/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/screens/doctor_dashboard_screen.dart';
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
import 'package:smart_clinic_booking/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/create_password_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/account_qr_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/qr_login_scanner_screen.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

import 'package:smart_clinic_booking/features/payment/presentation/screens/payment_screen.dart';
import 'package:smart_clinic_booking/features/payment/presentation/screens/transaction_screen.dart';
import 'package:smart_clinic_booking/features/medical_record/presentation/screens/medical_record_screen.dart';
import 'package:smart_clinic_booking/features/invoice/presentation/screens/invoice_screen.dart';
import 'package:smart_clinic_booking/core/security/auth_user.dart';

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

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStateChanges),
    redirect: (BuildContext context, GoRouterState state) async {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.uri.path;
      
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
      if (user == null) {
        if (isPublicRoute || (kDebugMode && path == '/home')) return null;
        return '/'; // Default to onboarding
      }

      // REQUIREMENT: Role-based navigation
      // For a simple system without Cloud Functions, we check claims first, then roles from Firestore if needed
      final idTokenResult = await user.getIdTokenResult(); 
      final claims = idTokenResult.claims ?? {};
      String role = claims['role'] as String? ?? 'unverified';
      
      // Special case for seed admin if claims are missing
      if (role == 'unverified' && user.email == 'admin@icare.com') {
        role = 'super_admin';
      }

      // 2. Pending KYC Approval Flow (for patients/new docs)
      final status = claims['status'] as String? ?? 'active';
      if (status == 'pending') {
        if (path != '/pending-approval' && path != '/kyc_upload') {
          return '/pending-approval';
        }
        return null;
      }

      // 3. User is Active but trying to view Onboarding / Login / Pending screens
      final bool isRegistrationFlow = path == '/verify-otp' || 
                                     path == '/create-password' || 
                                     path == '/account-qr';

      if ((isPublicRoute || path == '/pending-approval') && !isRegistrationFlow) {
         if (role == 'doctor') return '/doctor/dashboard';
         if (role == 'admin' || role == 'super_admin' || role == 'hospital_manager') return '/admin/dashboard';
         return '/home'; 
      }

      // 4. Strict Role-Based ACL checks
      if (path.startsWith('/admin') && role != 'super_admin' && role != 'admin' && role != 'hospital_manager') {
        return '/forbidden';
      }
      if (path.startsWith('/doctor') && role != 'doctor') {
        return '/forbidden';
      }
      
      // Authorized for generic or matching route
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
        builder: (context, state) => const HomeScreen(),
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
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'Your application is pending approval.',
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              '403 Forbidden - You lack permissions for this page.',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
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
    ],
  );
}

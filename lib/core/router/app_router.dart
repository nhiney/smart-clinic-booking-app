import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_clinic_booking/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_clinic_booking/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:smart_clinic_booking/features/home/presentation/screens/home_screen.dart';
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
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

// --- Placeholder Screens (For now) ---
class KycUploadScreen extends StatelessWidget {
  const KycUploadScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("KYC Upload Screen (Secure)")));
}

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Doctor Dashboard Screen")));
}

/// The global routing configuration adhering strictly to role-based access controls
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  
  redirect: (BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Allowed locations for unauthenticated users
    final bool isPublicRoute = state.matchedLocation == '/' || 
                               state.matchedLocation == '/login' || 
                               state.matchedLocation == '/sign-up';

    // 1. Unauthenticated users: Allow them to stay on public routes
    if (user == null) {
      if (isPublicRoute) return null; 
      return '/'; // Default to onboarding
    }

    // 2. Authenticated users:
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims ?? {};
    
    final String? role = claims['role'] as String?;
    final String? status = claims['status'] as String?;

    // Role-Based Redirect Logic
    if (role == 'patient') {
      if (isPublicRoute) return '/home';
      return null;
    } 
    else if (role == 'unverified' && status == 'pending') {
      if (state.matchedLocation != '/kyc_upload') return '/kyc_upload';
      return null;
    } 
    else if (role == 'doctor' && status == 'active') {
      if (isPublicRoute || state.matchedLocation == '/kyc_upload') {
        return '/doctor/dashboard';
      }
      return null;
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
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
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
      path: '/doctor/dashboard',
      builder: (context, state) => const DoctorDashboardScreen(),
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
  ],
);

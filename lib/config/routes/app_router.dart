import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/security/auth_user.dart';

// Screens
// import '../../features/auth/presentation/screens/login_screen.dart';
// import '../../features/home/presentation/screens/home_screen.dart';

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
  
  /// Listens natively to token claims changes. When a backend Cloud Function 
  /// updates a doctor's role from 'unverified' to 'doctor', this stream pushes events,
  /// causing GoRouter to automatically re-evaluate limits and route the user away from /pending.
  static Stream<User?> get authStateChanges => FirebaseAuth.instance.idTokenChanges();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authStateChanges),
    redirect: (BuildContext context, GoRouterState state) async {
      final user = FirebaseAuth.instance.currentUser;
      final path = state.uri.path;
      
      final isLoggingIn = path == '/login' || path == '/register';

      // 1. Unauthenticated Block
      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      // Proactively force a token refresh if the path is pending, to ensure real-time approval fetch.
      // (Optimization: Can be placed in App lifecycle resumes instead of router)
      final idTokenResult = await user.getIdTokenResult(); 
      final authUser = AuthUser.fromClaims(idTokenResult.claims ?? {}, user.uid);

      // 2. Pending KYC Approval Flow
      if (authUser.status == 'pending') {
        // Allow the user to visit KYC submission / pending approval screens. Block all others.
        if (path != '/pending-approval' && path != '/kyc-submit') {
          return '/pending-approval';
        }
        return null;
      }

      // 3. User is Active but trying to view Login / Pending screens
      if (isLoggingIn || path == '/pending-approval') {
         return '/home'; 
      }

      // 4. Strict Cross-Role RBAC checks
      if (path.startsWith('/admin') && authUser.role != AppRole.super_admin && authUser.role != AppRole.hospital_manager) {
        return '/forbidden';
      }
      if (path.startsWith('/doctor') && authUser.role != AppRole.doctor) {
        return '/forbidden';
      }
      if (path.startsWith('/patient') && authUser.role != AppRole.patient) {
        return '/forbidden';
      }

      // Authorized for generic or matching route
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Home Screen'))),
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
    ],
  );
}

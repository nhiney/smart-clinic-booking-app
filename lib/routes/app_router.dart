import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/config/routes/app_router.dart';
import '../features/auth/presentation/pages/register_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}

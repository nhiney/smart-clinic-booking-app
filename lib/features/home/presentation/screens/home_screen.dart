import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../appointment/presentation/screens/appointment_history_screen.dart';
import '../../../appointment/presentation/screens/booking_screen.dart';
import '../../../doctor/presentation/screens/doctor_list_screen.dart';
import '../../../doctor/presentation/screens/doctor_detail_screen.dart';
import '../../../medical_record/presentation/screens/medical_record_list_screen.dart';
import '../../../medication/presentation/screens/medication_screen.dart';
import '../../../notification/presentation/screens/notification_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../maps/presentation/screens/clinic_map_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_bloc_handler.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../widgets/medication_reminder_section.dart';
import '../widgets/health_summary_section.dart';
import '../widgets/ai_assistant_section.dart';
import '../widgets/recommended_doctors_section.dart';
import '../widgets/health_news_feed.dart';
import '../widgets/notifications_preview.dart';

/// Production Home Screen.
/// Orchestrates the Bloc, routes, and composes all 10 modular sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeDashboard(),
          MedicalRecordListScreen(),
          AppointmentHistoryScreen(),
          NotificationScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// Bottom Navigation Section (Section 10).
class _HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _HomeBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Trang chủ', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.folder_shared_rounded, label: 'Hồ sơ', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.calendar_month_rounded, label: 'Lịch hẹn', index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.notifications_rounded, label: 'Thông báo', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded, label: 'Tài khoản', index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard page — loads data via Bloc and renders all 10 sections.
class _HomeDashboard extends StatefulWidget {
  const _HomeDashboard();

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.id ?? '';
    context.read<HomeBlocHandler>().add(HomeLoadRequested(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBlocHandler, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const _LoadingView();
        }
        if (state is HomeError) {
          return _ErrorView(message: state.message, onRetry: _loadData);
        }
        if (state is HomeLoaded) {
          return _LoadedView(state: state);
        }
        return const _LoadingView();
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  final HomeLoaded state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userName = authController.currentUser?.name ?? 'Bạn';

    return RefreshIndicator(
      onRefresh: () async {
        final userId = authController.currentUser?.id ?? '';
        context.read<HomeBlocHandler>().add(HomeRefreshRequested(userId: userId));
      },
      child: CustomScrollView(
        slivers: [
          // Section 1: Header
          SliverToBoxAdapter(
            child: HomeHeader(
              userName: userName,
              unreadNotifications: state.upcomingAppointments.length,
              onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
              onProfileTap: () => Navigator.pushNamed(context, '/profile'),
              onVoiceTap: () {}, // AI voice shortcut
              onSearchSubmit: (query) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorListScreen()),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Section 2: Quick Actions
                  QuickActionsGrid(
                    onBookAppointment: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                    ),
                    onViewAppointments: () => Navigator.pushNamed(context, '/appointments'),
                    onMedicalRecords: () => Navigator.pushNamed(context, '/medical-records'),
                    onPrescriptions: () => Navigator.pushNamed(context, '/medication'),
                    onContactSupport: () {}, // Support chat
                    onVoiceAssistant: () {}, // AI chat
                  ),
                  const SizedBox(height: 28),

                  // Section 3: Upcoming Appointment
                  UpcomingAppointmentCard(
                    appointments: state.upcomingAppointments,
                    onViewAll: () => Navigator.pushNamed(context, '/appointments'),
                    onBook: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                    ),
                    onCancel: (apt) {}, // dispatch cancel event
                    onReschedule: (apt) {}, // navigate to reschedule
                  ),
                  const SizedBox(height: 28),

                  // Section 4: Medication Reminder
                  MedicationReminderSection(
                    reminders: state.medicationReminders,
                    onMarkTaken: (id) {
                      context.read<HomeBlocHandler>().add(
                            HomeMedicationMarkedTaken(reminderId: id),
                          );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Section 5: Health Summary
                  HealthSummarySection(summary: state.healthSummary),
                  const SizedBox(height: 28),

                  // Section 6: AI Assistant
                  AiAssistantSection(
                    onMessageSent: (msg) {}, // AI Bloc dispatch
                    onVoiceTap: () {}, // voice recognition
                    onOpenFullChat: () {}, // navigate to AI chat screen
                  ),
                  const SizedBox(height: 28),

                  // Section 7: Recommended Doctors
                  RecommendedDoctorsSection(
                    doctors: state.recommendedDoctors,
                    onViewAll: () => Navigator.pushNamed(context, '/doctors'),
                    onBookDoctor: (doc) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingScreen(doctor: doc)),
                    ),
                    onViewDoctor: (doc) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doc)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section 8: Health News
                  HealthNewsFeed(
                    articles: state.healthNews,
                    onArticleTap: (article) {}, // open article detail
                  ),
                  const SizedBox(height: 28),

                  // Section 9: Notifications Preview
                  NotificationsPreview(
                    notifications: const [], // TODO: wire notification data
                    onViewAll: () => Navigator.pushNamed(context, '/notifications'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

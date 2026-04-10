import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../notification/presentation/screens/notification_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_bloc_handler.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../widgets/hospital_banner.dart';
import '../widgets/health_news_feed.dart';
import '../widgets/featured_hospitals_section.dart';
import '../widgets/recommended_doctors_section.dart';
import '../widgets/medication_reminder_section.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeDashboard(
            onNotificationTap: () => setState(() => _currentIndex = 1),
          ),
          const NotificationScreen(),
          Center(child: Text(AppLocalizations.of(context)!.map_title, style: context.textStyles.heading3)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildAIButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    final l10n = AppLocalizations.of(context)!;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      color: context.colors.surface,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _navItem(0, Icons.home_rounded, l10n.home_welcome)),
            Expanded(child: _navItem(1, Icons.notifications_rounded, l10n.notification_title)),
            const SizedBox(width: 50), // Gap for FAB
            Expanded(child: _navItem(2, Icons.grid_view_rounded, l10n.map_title)),
            Expanded(
              child: _navItem(3, Icons.person_rounded, 'Của tôi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == 3) {
          context.push('/profile/patient');
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? context.colors.primary : context.colors.textHint,
            size: 26,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: context.textStyles.bodySmall.copyWith(
                  color: isSelected ? context.colors.primary : context.colors.textHint,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.4 * _pulseController.value),
                blurRadius: 18 * _pulseController.value,
                spreadRadius: 6 * _pulseController.value,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => context.push('/ai/voice-assistant'),
            backgroundColor: Colors.transparent,
            elevation: 8,
            child: Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiGradient,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 34),
            ),
          ),
        );
      },
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final VoidCallback onNotificationTap;
  const _HomeDashboard({required this.onNotificationTap});

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
    if (userId.isNotEmpty) {
      context.read<HomeBlocHandler>().add(HomeLoadRequested(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final userName = user?.name ?? 'Bạn';

    return BlocBuilder<HomeBlocHandler, HomeState>(
      builder: (context, state) {
        final appointments = state is HomeLoaded ? state.upcomingAppointments : <AppointmentEntity>[];
        final reminders = state is HomeLoaded ? state.medicationReminders : <MedicationReminder>[];
        final articles = state is HomeLoaded ? state.healthNews : <HealthArticle>[];
        final currentRole = user?.role ?? 'patient';

        return RefreshIndicator(
          onRefresh: () async {
            final userId = authController.currentUser?.id ?? '';
            context.read<HomeBlocHandler>().add(HomeRefreshRequested(userId: userId));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  userName: userName,
                  role: currentRole,
                  unreadNotifications: 0,
                  onNotificationTap: widget.onNotificationTap,
                  onProfileTap: () => context.push('/profile/patient'),
                  onVoiceTap: () => context.push('/ai/voice-assistant'),
                  onSearchSubmit: (v) {},
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    QuickActionsGrid(
                      userRole: currentRole,
                      onBookAppointment: () => context.push('/maps'),
                      onViewAppointments: () => context.push('/transactions'),
                      onMedicalRecords: () => context.push('/medical-records'),
                      onPrescriptions: () => context.push('/invoices'),
                      onContactSupport: () => context.push('/support'),
                      onVoiceAssistant: () => context.push('/ai/voice-assistant'),
                      onInpatientAdmission: () => context.push('/admission/registration/${user?.id ?? ""}'),
                      onNotificationSettings: () => context.push('/notifications/settings'),
                      onPricing: () => context.push('/payment', extra: {'amount': 500000, 'description': 'Thanh toán tạm ứng viện phí'}),
                      onSurveys: () => context.push('/surveys'),
                      onProfile: () => context.push('/profile/patient'),
                    ),

                    const SizedBox(height: 24),
                    UpcomingAppointmentCard(
                      appointments: appointments,
                      onViewAll: () {},
                      onBook: () {},
                      onCancel: (a) {},
                      onReschedule: (a) {},
                    ),
                    const SizedBox(height: 24),
                    MedicationReminderSection(
                      reminders: reminders,
                      onMarkTaken: (id) {
                        context.read<HomeBlocHandler>().add(HomeMedicationMarkedTaken(reminderId: id));
                      },
                    ),
                    const SizedBox(height: 24),
                    const HospitalBanner(),
                    const SizedBox(height: 24),
                    const FeaturedHospitalsSection(),
                    const SizedBox(height: 24),
                    const RecommendedDoctorsSection(),
                    const SizedBox(height: 24),
                    HealthNewsFeed(
                      articles: articles,
                      onArticleTap: (a) {},
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthController>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

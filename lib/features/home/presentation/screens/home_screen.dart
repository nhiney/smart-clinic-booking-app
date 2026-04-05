import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_bloc_handler.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../widgets/hospital_banner.dart';
import '../widgets/health_news_feed.dart';
import '../widgets/recommended_doctors_section.dart';
import '../widgets/medication_reminder_section.dart';
import '../widgets/prominent_hospitals_section.dart';

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
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeDashboard(),
          const Center(child: Text('Thông báo')),
          const Center(child: Text('Chức năng')),
          const Center(child: Text('Cá nhân')),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildAIButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 20,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _navItem(0, Icons.home_rounded, 'Trang chủ')),
            Expanded(child: _navItem(1, Icons.notifications_rounded, 'Thông báo')),
            const SizedBox(width: 50), // Gap for FAB
            Expanded(child: _navItem(2, Icons.grid_view_rounded, 'Chức năng')),
            Expanded(child: _navItem(3, Icons.person_rounded, 'Cá nhân')),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : const Color(0xFF90A4AE),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : const Color(0xFF90A4AE),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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
                color: AppColors.primary.withOpacity(0.4 * _pulseController.value),
                blurRadius: 18 * _pulseController.value,
                spreadRadius: 6 * _pulseController.value,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {},
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
    if (userId.isNotEmpty) {
      context.read<HomeBlocHandler>().add(HomeLoadRequested(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final userName = user?.name ?? 'Bạn';
    final userRole = user?.role ?? 'patient';

    return BlocBuilder<HomeBlocHandler, HomeState>(
      builder: (context, state) {
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
                  role: userRole,
                  unreadNotifications: state is HomeLoaded ? state.upcomingAppointments.length : 3,
                  onNotificationTap: () {},
                  onProfileTap: () {},
                  onVoiceTap: () {},
                  onSearchSubmit: (q) {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: QuickActionsGrid(
                  userRole: userRole,
                  onBookAppointment: () {},
                  onViewAppointments: () {},
                  onMedicalRecords: () {},
                  onPrescriptions: () {},
                  onContactSupport: () {},
                  onVoiceAssistant: () {},
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              const SliverToBoxAdapter(child: HospitalBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              if (state is HomeLoaded) ...[
                SliverToBoxAdapter(
                  child: UpcomingAppointmentCard(
                    appointments: state.upcomingAppointments,
                    onViewAll: () {},
                    onBook: () {},
                    onCancel: (apt) {},
                    onReschedule: (apt) {},
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                if (userRole == 'patient') ...[
                  SliverToBoxAdapter(
                    child: MedicationReminderSection(
                      reminders: state.medicationReminders,
                      onMarkTaken: (id) {},
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
                const SliverToBoxAdapter(child: ProminentHospitalsSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverToBoxAdapter(
                  child: RecommendedDoctorsSection(
                    doctors: state.recommendedDoctors,
                    onViewAll: () {},
                    onBookDoctor: (doc) {},
                    onViewDoctor: (doc) {},
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverToBoxAdapter(
                  child: HealthNewsFeed(
                    articles: state.healthNews,
                    onArticleTap: (article) {},
                  ),
                ),
              ] else if (state is HomeLoading) ...[
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

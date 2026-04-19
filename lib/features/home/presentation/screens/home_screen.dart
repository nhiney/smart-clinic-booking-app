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
import '../widgets/consulting_doctors_section.dart';
import '../widgets/medical_facilities_section.dart';
import '../widgets/care_section.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';

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
import '../widgets/hospital_banner.dart';

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
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeDashboard(),
          const NotificationScreen(),
          Center(child: Text('Chức năng', style: context.textStyles.heading3)),
          Center(child: Text('Cá nhân', style: context.textStyles.heading3)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            context.push('/profile/patient');
          } else if (index == 2) {
             setState(() => _currentIndex = index);
          } else {
             setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D62A2),
        unselectedItemColor: const Color(0xFF546E7A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded, size: 28)),
            label: 'Trang chủ',
          ),
           BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 28),
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('10', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.layers_outlined, size: 28)),
            label: 'Chức năng',
          ),
          const BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline_rounded, size: 28)),
            label: 'Cá nhân',
          ),
        ],
      ),
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
    final currentRole = user?.role ?? 'patient';

    return BlocBuilder<HomeBlocHandler, HomeState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            final userId = authController.currentUser?.id ?? '';
            context.read<HomeBlocHandler>().add(HomeRefreshRequested(userId: userId));
          },
          child: Container(
            // Toàn bộ màn hình có nền gradient phía sau
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD4EFFF), // xanh dương nhạt nhất ở trên cùng
                  Color(0xFFEAF6FF),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 0.6],
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                const SliverToBoxAdapter(
                  child: HomeHeader(), // header đã được bỏ margin thừa
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 4), // Khoảng trống nhỏ trên đầu lưới
                        QuickActionsGrid(
                          userRole: currentRole,
                          onBookAppointment: () => context.push('/maps'),
                          onViewAppointments: () => context.push('/appointments'),
                          onMedicalRecords: () => context.push('/medical-records'),
                          onPrescriptions: () => context.push('/prescriptions'),
                          onContactSupport: () => context.push('/support'),
                          onVoiceAssistant: () => context.push('/ai/voice-assistant'),
                          onInpatientAdmission: () => context.push('/admission/registration/${user?.id ?? ""}'),
                          onNotificationSettings: () => context.push('/notifications/settings'),
                          onPricing: () => context.push('/transactions'),
                          onSurveys: () => context.push('/surveys'),
                          onProfile: () => context.push('/profile/patient'),
                        ),
                        // The big hospital banner image
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://images.sampletemplates.com/wp-content/uploads/2016/03/Patient-Logo-Template.jpg',
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

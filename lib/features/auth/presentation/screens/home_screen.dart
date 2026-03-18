import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../doctor/presentation/screens/doctor_list_screen.dart';
import '../../../appointment/presentation/screens/appointment_history_screen.dart';

import '../../../medical_record/presentation/screens/medical_record_list_screen.dart';
import '../../../medication/presentation/screens/medication_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../maps/presentation/screens/clinic_map_screen.dart';
import '../../../notification/presentation/screens/notification_screen.dart';
import '../../../doctor/presentation/controllers/doctor_controller.dart';
import '../../../appointment/presentation/controllers/appointment_controller.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _HomeDashboard(),
    AppointmentHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final userName = auth.currentUser?.name ?? 'bạn';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with greeting
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào,',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                userName,
                                style: AppTextStyles.heading3.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Quick Actions
                SectionHeader(title: "Dịch vụ"),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.search,
                            label: "Tìm bác sĩ",
                            color: AppColors.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            context,
                            icon: Icons.calendar_today,
                            label: "Lịch hẹn",
                            color: AppColors.success,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            context,
                            icon: Icons.folder_outlined,
                            label: "Bệnh án",
                            color: AppColors.warning,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MedicalRecordListScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildQuickAction(
                            context,
                            icon: Icons.medication,
                            label: "Thuốc",
                            color: AppColors.error,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MedicationScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickAction(
                            context,
                            icon: Icons.map,
                            label: "Bản đồ",
                            color: AppColors.info,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ClinicMapScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Spacer(),
                          const SizedBox(width: 12),
                          const Spacer(),
                          const SizedBox(width: 12),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming Appointments
                SectionHeader(
                  title: "Lịch hẹn sắp tới",
                  actionText: "Xem tất cả",
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<AppointmentController>(
                  builder: (_, controller, __) {
                    final upcoming = controller.upcomingAppointments;
                    if (upcoming.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: AppColors.shadow, blurRadius: 8),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 32, color: AppColors.textHint),
                              const SizedBox(height: 8),
                              Text(
                                "Chưa có lịch hẹn",
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                                ),
                                child: const Text("Đặt lịch ngay"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: upcoming.length > 2 ? 2 : upcoming.length,
                      itemBuilder: (_, index) {
                        final apt = upcoming[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: AppColors.shadow, blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(apt.doctorName, style: AppTextStyles.subtitle),
                                    Text(apt.specialty, style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${apt.dateTime.day}/${apt.dateTime.month}",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')}",
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Top Doctors
                SectionHeader(
                  title: "Bác sĩ nổi bật",
                  actionText: "Xem tất cả",
                  onActionTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<DoctorController>(
                  builder: (_, controller, __) {
                    if (controller.doctors.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Đang tải..."),
                      );
                    }

                    final topDoctors = controller.doctors.take(3).toList();
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: topDoctors.length,
                        itemBuilder: (_, index) {
                          final doc = topDoctors[index];
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: AppColors.shadow, blurRadius: 8),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.primarySurface,
                                  child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  doc.name,
                                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doc.specialty,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                                    const SizedBox(width: 2),
                                    Text(
                                      doc.rating.toStringAsFixed(1),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

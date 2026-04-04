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
import '../../../notification/presentation/screens/notification_screen.dart';
import '../../../doctor/presentation/controllers/doctor_controller.dart';
import '../../../appointment/presentation/controllers/appointment_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _HomeDashboard(),
    MedicalRecordListScreen(),
    AppointmentHistoryScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared),
            label: 'Hồ sơ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Phiếu khám',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
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
    // User greeting handled in header

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with greeting
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: const Color(0xFFE3F2FD),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBBDEFB), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_hospital, color: Color(0xFF2196F3), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'ICare xin chào,',
                            style: AppTextStyles.heading3.copyWith(
                              color: const Color(0xFF0D47A1),
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Tất cả/VI",
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Tìm CSYT/bác sĩ/chuyên khoa/dịch vụ',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                          Icon(Icons.search, color: Colors.grey.shade400),
                        ],
                      ),
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

                // Quick Actions Grid (8 items)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        _buildServiceItem(
                          context,
                          icon: Icons.calendar_month,
                          label: "Đặt khám tại cơ sở",
                          color: Colors.blue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListScreen())),
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.medical_services,
                          label: "Đặt khám chuyên khoa",
                          color: Colors.lightBlue,
                          onTap: () {},
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.biotech,
                          label: "Đặt lịch xét nghiệm",
                          color: Colors.blueAccent,
                          onTap: () {},
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.health_and_safety,
                          label: "Gói sức khỏe toàn diện",
                          color: Colors.blueGrey,
                          onTap: () {},
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.people,
                          label: "Giúp việc cá nhân",
                          color: Colors.cyan,
                          onTap: () {},
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.videocam,
                          label: "Gọi video với bác sĩ",
                          color: Colors.teal,
                          onTap: () {},
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.shopping_bag,
                          label: "Mua thuốc tại An Khang",
                          color: Colors.green,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationScreen())),
                        ),
                        _buildServiceItem(
                          context,
                          icon: Icons.business,
                          label: "Khám doanh nghiệp",
                          color: Colors.indigo,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Partners Section
                Center(
                  child: Text(
                    "ĐƯỢC TIN TƯỞNG HỢP TÁC VÀ ĐỒNG HÀNH",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildPartnerLogo("Bệnh viện Chợ Rẫy", Icons.local_hospital),
                      _buildPartnerLogo("Bệnh viện Mắt", Icons.visibility),
                      _buildPartnerLogo("BV Nhân Dân Gia Định", Icons.apartment),
                      _buildPartnerLogo("BV Trung Vương", Icons.domain),
                      _buildPartnerLogo("BV Da Liễu", Icons.health_and_safety),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Dot indicator for partners
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: index == 1 ? 12 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: index == 1 ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
                const SizedBox(height: 24),

                // Banner Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade100, Colors.white],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Giải pháp quản lý",
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "PHÒNG MẠCH",
                                    style: AppTextStyles.heading3.copyWith(color: Colors.blue, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Icon(Icons.medical_information, size: 80, color: Colors.blue.withOpacity(0.2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Medical Facilities Section
                SectionHeader(
                  title: "Cơ sở y tế",
                  actionText: "Xem tất cả",
                  onActionTap: () {},
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFacilityCard(
                        "Bệnh viện Đại học Y Dược TP.HCM",
                        "Hồng Bàng, Q.5, TP.HCM",
                        4.7,
                        Icons.apartment,
                      ),
                      _buildFacilityCard(
                        "Bệnh viện Nhân Dân Gia Định (Cơ sở 2)",
                        "Quận 1, TP.HCM",
                        5.0,
                        Icons.business,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 32, color: AppColors.textHint),
                              const SizedBox(height: 8),
                              const Text("Chưa có lịch hẹn"),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DoctorListScreen()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: topDoctors.length,
                        itemBuilder: (_, index) {
                          final doc = topDoctors[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue.shade50,
                                      child: const Icon(Icons.person, color: Colors.blue, size: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  doc.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.check_circle, color: Colors.blue, size: 14),
                                            ],
                                          ),
                                          Text(doc.specialty, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.orange.shade400, size: 14),
                                    const SizedBox(width: 4),
                                    Text(doc.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    const Text(
                                      "Tư vấn video",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE3F2FD),
                                      foregroundColor: Colors.blue,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text("Tư vấn ngay", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
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

  Widget _buildFacilityCard(String name, String address, double rating, IconData icon) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange.shade400, size: 14),
              const SizedBox(width: 4),
              Text(rating.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text("Đặt ngay", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String name, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blue.shade900, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_quick_action_button.dart';
import '../widgets/hospital_list_item.dart';
import 'department_management_screen.dart';
import 'add_doctor_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchHospitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final authController = context.watch<AuthController>();
    final adminName = authController.currentUser?.name ?? 'Admin';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _currentIndex == 0 
        ? null // Custom drawing for dashboard home
        : AppBar(
            elevation: 0,
            backgroundColor: context.colors.primarySurface,
            title: Text(
              _currentIndex == 1 ? 'Quản lý Bệnh viện' : 'Quản lý Bác sĩ',
              style: context.textStyles.heading3.copyWith(color: context.colors.primaryDark),
            ),
            actions: [
              IconButton(
                icon: Icon(_currentIndex == 1 ? Icons.add_business_rounded : Icons.person_add_rounded),
                onPressed: () {
                  if (_currentIndex == 1) {
                    _showAddHospitalDialog(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
                    );
                  }
                },
              ),
            ],
          ),
      drawer: _buildDrawer(context),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboardHub(context, controller, adminName),
                _buildHospitalList(controller),
                _buildDoctorList(controller),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: context.colors.surface,
          selectedItemColor: context.colors.primary,
          unselectedItemColor: context.colors.textHint,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_rounded),
              activeIcon: Icon(Icons.business_rounded),
              label: 'Bệnh viện',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              activeIcon: Icon(Icons.people_alt_rounded),
              label: 'Bác sĩ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHub(BuildContext context, AdminController controller, String adminName) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Gradient
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, context.spacing.xxl, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: context.textStyles.body.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          adminName,
                          style: context.textStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Compact Announcement box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: context.radius.lRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hệ thống đang hoạt động ổn định. Đã có 5 cuộc hẹn mới trong hôm nay.',
                          style: context.textStyles.bodySmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số liệu thống kê', style: context.textStyles.bodyBold),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.12,
                  children: [
                    AdminStatCard(
                      title: 'Bệnh viện',
                      value: controller.hospitals.length.toString(),
                      icon: Icons.business_rounded,
                      color: Colors.blue,
                    ),
                    AdminStatCard(
                      title: 'Bác sĩ',
                      value: controller.allDoctors.length.toString(),
                      icon: Icons.people_alt_rounded,
                      color: Colors.teal,
                    ),
                    const AdminStatCard(
                      title: 'Bệnh nhân',
                      value: '124', // Placeholder for now
                      icon: Icons.person_rounded,
                      color: Colors.orange,
                    ),
                    const AdminStatCard(
                      title: 'Lịch hẹn',
                      value: '48', // Placeholder for now
                      icon: Icons.event_available_rounded,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Thao tác nhanh', style: context.textStyles.bodyBold),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.72,
                  children: [
                    AdminQuickActionButton(
                      label: 'Thêm BV',
                      icon: Icons.add_business_rounded,
                      onTap: () => _showAddHospitalDialog(context),
                    ),
                    AdminQuickActionButton(
                      label: 'Thêm Bác sĩ',
                      icon: Icons.person_add_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDoctorScreen())),
                    ),
                    AdminQuickActionButton(
                      label: 'Dữ liệu y tế',
                      icon: Icons.auto_fix_high_rounded,
                      onTap: () async {
                        await controller.seedData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật dữ liệu Bệnh viện & Khoa mẫu!')),
                          );
                        }
                      },
                    ),
                    AdminQuickActionButton(
                      label: 'Thêm BN mẫu',
                      icon: Icons.group_add_rounded,
                      onTap: () async {
                        try {
                          await controller.seedPatients();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã tạo 5 bệnh nhân mẫu thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${e.toString()}'),
                                backgroundColor: context.colors.error,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    AdminQuickActionButton(
                      label: 'Báo cáo',
                      icon: Icons.analytics_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalList(AdminController controller) {
    if (controller.hospitals.isEmpty) return _buildEmptyState('Chưa có bệnh viện nào');
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: controller.hospitals.length,
      itemBuilder: (context, index) {
        final hospital = controller.hospitals[index];
        return HospitalListItem(
          hospital: hospital,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DepartmentManagementScreen(hospital: hospital),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorList(AdminController controller) {
    if (controller.allDoctors.isEmpty) return _buildEmptyState('Chưa có bác sĩ nào');
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: controller.allDoctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.allDoctors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: context.radius.mRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              backgroundImage: doctor.imageUrl.isNotEmpty ? NetworkImage(doctor.imageUrl) : null,
              child: doctor.imageUrl.isEmpty
                  ? Icon(Icons.person_rounded, color: context.colors.primary, size: 28)
                  : null,
            ),
            title: Text(doctor.name, style: context.textStyles.bodyBold),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${doctor.specialty}', style: context.textStyles.bodySmall.copyWith(color: context.colors.primary)),
                Text('${doctor.hospital}', style: context.textStyles.bodySmall),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // Navigation to doctor details
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: context.textStyles.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddHospitalDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
            ),
            child: const Text('Bắt đầu ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: context.colors.primary),
            accountName: Text(context.watch<AuthController>().currentUser?.name ?? 'Admin', style: context.textStyles.bodyBold.copyWith(color: Colors.white)),
            accountEmail: Text(context.watch<AuthController>().currentUser?.email ?? 'admin@icare.com', style: context.textStyles.bodySmall.copyWith(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                (context.watch<AuthController>().currentUser?.name ?? 'A').substring(0, 1),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Cài đặt hệ thống'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded),
            title: const Text('Thông báo hệ thống'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Trợ giúp & Hỗ trợ'),
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _handleLogout(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddHospitalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Bệnh viện mới'),
        content: const Text('Vui lòng nhập thông tin bệnh viện để bắt đầu quản lý.'),
        shape: RoundedRectangleBorder(borderRadius: context.radius.lRadius),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy bỏ')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tiếp tục')),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn rời khỏi bảng điều khiển quản trị?'),
        shape: RoundedRectangleBorder(borderRadius: context.radius.lRadius),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Trở lại'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthController>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

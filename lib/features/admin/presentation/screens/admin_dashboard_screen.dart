import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import 'department_management_screen.dart';
import 'add_doctor_screen.dart';
import '../../../admin/presentation/screens/add_clinic_screen.dart';
import '../../../admin/presentation/screens/admin_statistics_screen.dart';

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
      final ctrl = context.read<AdminController>();
      ctrl.fetchHospitals();
      ctrl.fetchUnassignedDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(_getTitle(), style: context.textStyles.heading3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _refreshData(controller),
          ),
          if (_currentIndex == 1 || _currentIndex == 2)
            IconButton(
              icon: Icon(_currentIndex == 1 
                ? Icons.add_business_rounded 
                : Icons.person_add_rounded),
              onPressed: () => _currentIndex == 1 
                ? _showAddHospitalDialog(context) 
                : Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDoctorScreen())),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                const AdminStatisticsScreen(),
                _buildHospitalList(controller),
                _buildDoctorApprovalList(controller),
                _buildUserManagementList(controller),
              ],
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.black38,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.maps_home_work_outlined), 
            activeIcon: Icon(Icons.maps_home_work), 
            label: 'Bệnh viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing_outlined), 
            activeIcon: Icon(Icons.healing_rounded),
            label: 'Bác sĩ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), 
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Tổng quan hệ thống';
      case 1: return 'Quản lý Bệnh viện';
      case 2: return 'Duyệt hồ sơ Bác sĩ';
      case 3: return 'Cài đặt hệ thống';
      default: return 'Admin Dashboard';
    }
  }

  void _refreshData(AdminController controller) {
    controller.fetchHospitals();
    controller.fetchUnassignedDoctors();
  }

  Widget _buildDoctorApprovalList(AdminController controller) {
    if (controller.allDoctors.isEmpty) return _buildEmptyState('Không có yêu cầu duyệt');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.allDoctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.allDoctors[index];
        return Card(
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(doctor.name, style: context.textStyles.bodyBold),
            subtitle: Text(doctor.specialty),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Từ chối')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {}, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Duyệt hồ sơ'),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserManagementList(AdminController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_circle_rounded, size: 40),
            title: const Text('Nguyễn Văn B'),
            subtitle: const Text('Phân quyền: Bệnh nhân'),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'block', child: Text('Khóa tài khoản', style: TextStyle(color: Colors.red))),
                const PopupMenuItem(value: 'role', child: Text('Sửa phân quyền')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHospitalList(AdminController controller) {
    if (controller.hospitals.isEmpty) return _buildEmptyState('Chưa có bệnh viện nào');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.hospitals.length,
      itemBuilder: (context, index) => _buildHospitalCard(context, controller.hospitals[index]),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: context.colors.textHint.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: context.textStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(BuildContext context, dynamic hospital) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DepartmentManagementScreen(hospital: hospital),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hospital.logoUrl.isNotEmpty
                    ? Image.network(hospital.logoUrl, errorBuilder: (_, __, ___) => Icon(Icons.business_rounded, color: context.colors.primary))
                    : Icon(Icons.business_rounded, color: context.colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name, style: context.textStyles.bodyBold.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(hospital.address, style: context.textStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHospitalDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddClinicScreen(),
        fullscreenDialog: true, 
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống quản trị?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
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
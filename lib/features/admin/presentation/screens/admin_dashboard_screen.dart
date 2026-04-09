import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
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
      context.read<AdminController>().fetchUnassignedDoctors(); // For unassigned, or we can fetch all
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Quản lý Bệnh viện' : 'Quản lý Bác sĩ',
          style: context.textStyles.heading3,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Seed Initial Data',
            onPressed: () async {
              await controller.seedData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dữ liệu hệ thống đã được cập nhật thành công!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(_currentIndex == 0 ? Icons.add_business_rounded : Icons.person_add_rounded),
            onPressed: () {
              if (_currentIndex == 0) {
                _showAddHospitalDialog(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
                );
              }
            },
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
                _buildHospitalList(controller),
                _buildDoctorList(controller),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.business_rounded), label: 'Bệnh viện'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Bác sĩ'),
        ],
      ),
    );
  }

  Widget _buildHospitalList(AdminController controller) {
    if (controller.hospitals.isEmpty) return _buildEmptyState('Chưa có bệnh viện nào');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.hospitals.length,
      itemBuilder: (context, index) {
        final hospital = controller.hospitals[index];
        return _buildHospitalCard(context, hospital);
      },
    );
  }

  Widget _buildDoctorList(AdminController controller) {
    if (controller.allDoctors.isEmpty) return _buildEmptyState('Chưa có bác sĩ nào');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.allDoctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.allDoctors[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.primary.withOpacity(0.1),
              child: Icon(Icons.person_rounded, color: context.colors.primary),
            ),
            title: Text(doctor.name, style: context.textStyles.bodyBold),
            subtitle: Text('${doctor.specialty} • ${doctor.hospital}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // Navigation to doctor details if needed
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
          Icon(Icons.business_rounded, size: 80, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Chưa có bệnh viện nào', style: context.textStyles.bodyLarge),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddHospitalDialog(context),
            child: const Text('Thêm Bệnh viện đầu tiên'),
          ),
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
    // Basic dialog for demonstration
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Bệnh viện'),
        content: const Text('Giao diện thêm bệnh viện sẽ được hoàn thiện sau.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
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

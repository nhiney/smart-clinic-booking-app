import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/features/admin/presentation/screens/admin_patient_management_screen.dart';
import '../../../../core/extensions/context_extension.dart';
import '../controllers/admin_controller.dart';
import 'admin_hospital_management_screen.dart';
import 'admin_doctor_management_screen.dart';
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
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
          : IndexedStack(
              index: _currentIndex,
              children: [
                const AdminStatisticsScreen(),
                const AdminHospitalManagementScreen(),
                const AdminDoctorManagementScreen(),
                _buildSystemSettingsView(controller),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1E88E5),
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

  Widget _buildSystemSettingsView(AdminController controller) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Text('Cài đặt hệ thống', style: context.textStyles.heading3),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.account_circle_rounded, size: 40, color: Colors.black38),
              title: const Text('Nguyễn Văn B', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Phân quyền: Bệnh nhân'),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'block',
                    child: Text('Khóa tài khoản', style: TextStyle(color: Colors.red)),
                  ),
                  const PopupMenuItem(value: 'role', child: Text('Sửa phân quyền')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
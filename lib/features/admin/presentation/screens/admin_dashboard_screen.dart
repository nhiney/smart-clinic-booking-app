import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/facility_entities.dart';
import '../controllers/admin_controller.dart';
import 'add_doctor_screen.dart';
import 'admin_revenue_screen.dart'; 
import '../widgets/admin_content_view.dart';

import '../widgets/hospital_management_view.dart';
import '../widgets/admin_settings_view.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_title_section.dart';
import '../widgets/dashboard_period_selector.dart';
import '../widgets/main_appointment_card.dart';
import '../widgets/secondary_stats_grid.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/doctor_approval_card.dart';
import '../widgets/doctor_search_bar.dart';
import '../widgets/doctor_status_tab_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  String _activeDoctorTab = 'Chờ duyệt';
  String _searchDoctorQuery = '';

  List<dynamic> _filteredDoctors = [];
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchHospitals();
    });
  }

  void _filterAndCountDoctors(AdminController controller) {
    _pendingCount = 0;
    _approvedCount = 0;
    _rejectedCount = 0;

    _filteredDoctors = controller.allDoctors.where((doctor) {
      Map<String, dynamic> dMap = {};
      try { dMap = (doctor as dynamic).toMap(); } catch (_) {}
      
      final String docStatus = dMap['status'] ?? 'pending';

      if (docStatus == 'pending' || docStatus.isEmpty) {
        _pendingCount++;
      } else if (docStatus == 'approved') {
        _approvedCount++;
      } else if (docStatus == 'rejected') {
        _rejectedCount++;
      }

      bool matchesStatus = false;
      if (_activeDoctorTab == 'Chờ duyệt') {
        matchesStatus = (docStatus == 'pending' || docStatus.isEmpty);
      } else if (_activeDoctorTab == 'Đã duyệt') {
        matchesStatus = (docStatus == 'approved');
      } else {
        matchesStatus = (docStatus == 'rejected');
      }

      bool matchesSearch = doctor.name.toLowerCase().contains(_searchDoctorQuery.toLowerCase()) ||
          (doctor.specialty ?? '').toLowerCase().contains(_searchDoctorQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    _filterAndCountDoctors(controller);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: _currentIndex == 0 || _currentIndex == 3
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                _currentIndex == 1 
                    ? 'Bệnh viện' 
                    : _currentIndex == 2 
                        ? 'Bác sĩ' 
                        : 'Cài đặt hệ thống',
                style: context.textStyles.heading3.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: (context.textStyles.heading3.fontSize ?? 18) + 2
                ),
              ),
              actions: [
                if (_currentIndex == 1 || _currentIndex == 2)
                  IconButton(
                    icon: Icon(_currentIndex == 1 ? Icons.local_hospital_rounded : Icons.add_outlined),
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
      body: () {
        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Lỗi hệ thống: ${controller.errorMessage}', style: context.textStyles.body),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchHospitals(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.isLoading && controller.dashboardData == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }

        if (controller.dashboardData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.grey, size: 60),
                const SizedBox(height: 16),
                Text('Không có dữ liệu tổng quan', style: context.textStyles.body),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.seedData(),
                  child: const Text('Khởi tạo dữ liệu mẫu'),
                ),
              ],
            ),
          );
        }

        return IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardHub(context, controller),
            _buildHospitalList(controller),
            _buildDoctorList(controller),
            AdminContentView(articles: controller.articles), // 🌟 Tab Nội dung động (Hình 2)
            AdminSettingsView(
              onLogoutTap: () => _handleLogout(context),
            ),
          ],
        );
      }(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 22), activeIcon: Icon(Icons.home_rounded, size: 22), label: 'Tổng quan'),
            BottomNavigationBarItem(icon: Icon(Icons.business_outlined, size: 22), activeIcon: Icon(Icons.business_rounded, size: 22), label: 'Bệnh viện'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded, size: 22), activeIcon: Icon(Icons.people_alt_rounded, size: 22), label: 'Bác sĩ'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined, size: 22), activeIcon: Icon(Icons.article_rounded, size: 22), label: 'Nội dung'), // Tab mới
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined, size: 22), activeIcon: Icon(Icons.settings_rounded, size: 22), label: 'Cài đặt'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHub(BuildContext context, AdminController controller) {
    final data = controller.dashboardData;
    if (data == null) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () async {
        await context.read<AdminController>().fetchDashboardOverview();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            DashboardHeader(data: data),
            const SizedBox(height: 20),
            DashboardTitleSection(data: data),
            const SizedBox(height: 16),
            DashboardPeriodSelector(controller: controller),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminRevenueScreen(dashboardData: data),
                  ),
                );
              },
              child: MainAppointmentCard(
                appointments: data.appointments, 
                currentPeriod: controller.selectedPeriod,
              ),
            ),
            
            const SizedBox(height: 16),
            SecondaryStatsGrid(data: data),
            const SizedBox(height: 24),
            Text('Thao tác nhanh', style: context.textStyles.bodyBold),
            const SizedBox(height: 12),
            QuickActionsGrid(
              controller: controller,
              onAddHospitalTap: () => _showAddHospitalDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalList(AdminController controller) {
    return HospitalManagementView(controller: controller);
  }

  Widget _buildDoctorList(AdminController controller) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                DoctorSearchBar(
                  onChanged: (value) => setState(() => _searchDoctorQuery = value),
                ),
                const SizedBox(height: 16),
                DoctorStatusTabBar(
                  activeTab: _activeDoctorTab,
                  counts: {
                    'Chờ duyệt': _pendingCount,
                    'Đã duyệt': _approvedCount,
                    'Từ chối': _rejectedCount,
                  },
                  onTabChanged: (tab) => setState(() => _activeDoctorTab = tab),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredDoctors.isEmpty
                ? _buildEmptyState('Không có bác sĩ nào trong danh sách $_activeDoctorTab')
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      
                      Map<String, dynamic> currentDocMap = {};
                      try { currentDocMap = (doctor as dynamic).toMap(); } catch (_) {}

                      return DoctorApprovalCard(
                        doctor: doctor,
                        onApprove: () async {
                          await controller.assignDoctor(
                            doctorId: doctor.id,
                            hospitalId: currentDocMap['hospitalId'] ?? '',
                            departmentId: currentDocMap['departmentId'] ?? '',
                          );
                          await controller.fetchAllDoctors();
                          setState(() {});
                        },
                        onReject: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã từ chối hồ sơ của BS. ${doctor.name}')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
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
              child: Text((context.watch<AuthController>().currentUser?.name ?? 'A').substring(0, 1), style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.red), title: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: () => _handleLogout(context)),
        ],
      ),
    );
  }

  void _showAddHospitalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final hoursCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final adminController = context.read<AdminController>();
    bool isSaving = false;

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Thêm Bệnh viện mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: deco('Tên bệnh viện *')),
                const SizedBox(height: 12),
                TextField(controller: addressCtrl, decoration: deco('Địa chỉ')),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: deco('Số điện thoại')),
                const SizedBox(height: 12),
                TextField(controller: hoursCtrl, decoration: deco('Giờ làm việc (VD: 7:00 - 17:00)')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 2, decoration: deco('Mô tả')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Hủy bỏ'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập tên bệnh viện.')),
                        );
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      try {
                        await adminController.addHospital(Hospital(
                          id: 'hosp_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          address: addressCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          workingHours: hoursCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                        ));
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm bệnh viện thành công.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthController>().logout();
  }
}
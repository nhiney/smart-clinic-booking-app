import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import '../screens/audit_log_screen.dart';
import 'admin_setting_tile.dart';

class AdminSettingsView extends StatelessWidget {
  final VoidCallback onLogoutTap;
  const AdminSettingsView({super.key, required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final adminController = context.watch<AdminController>();
    final user = authController.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProfileHeader(user),
        const SizedBox(height: 24),
        
        _buildSectionTitle('TÌNH TRẠNG HỆ THỐNG'),
        _buildSystemStatusGrid(adminController.systemServices),
        
        const SizedBox(height: 24),
        _buildSectionTitle('QUẢN LÝ'),
        _buildManagementCard(context),
        
        const SizedBox(height: 24),
        _buildSectionTitle('ỨNG DỤNG & HỖ TRỢ'),
        _buildSupportCard(),
        
        const SizedBox(height: 24),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(radius: 32, child: Text((user?.name ?? 'A')[0])),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text("ROOT ACCESS", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusGrid(List<SystemServiceEntity> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final s = services[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Text(s.name, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              Icon(Icons.circle, size: 8, color: s.status == 'active' ? Colors.green : Colors.orange),
              const SizedBox(width: 4),
              Text("${s.latency}ms", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManagementCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          AdminSettingTile(
            icon: Icons.history_rounded, 
            iconColor: Colors.purple, 
            title: 'Nhật ký truy cập', 
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AuditLogScreen()),
              );
            }
          ),
          const Divider(height: 1, indent: 56),
          AdminSettingTile(
            icon: Icons.shield_outlined,
            iconColor: Colors.blue,
            title: 'Phân quyền & vai trò',
            onTap: () => _showInfoDialog(
              context,
              'Phân quyền & vai trò',
              'Các vai trò: Quản trị (super_admin/hospital_manager), Bác sĩ, '
                  'Bệnh nhân, Thiết bị quét. Quyền được cấp qua custom claims khi '
                  'đăng ký/duyệt hồ sơ.',
            ),
          ),
          const Divider(height: 1, indent: 56),
          AdminSettingTile(
            icon: Icons.description_outlined,
            iconColor: Colors.green,
            title: 'Cấu hình BHYT',
            onTap: () => _showInfoDialog(context, 'Cấu hình BHYT', 'Tính năng đang được phát triển.'),
          ),
          const Divider(height: 1, indent: 56),
          AdminSettingTile(
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.amber,
            title: 'Phí dịch vụ & hoa hồng',
            onTap: () => _showInfoDialog(context, 'Phí dịch vụ & hoa hồng', 'Tính năng đang được phát triển.'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Builder(
      builder: (context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AdminSettingTile(
          icon: Icons.info_outline,
          iconColor: Colors.teal,
          title: 'Thông tin phiên bản',
          subtitle: 'v1.0.0',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'iCare Pro — Quản trị',
            applicationVersion: 'v1.0.0',
            children: const [Text('Hệ thống quản lý phòng khám thông minh ICare.')],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AdminSettingTile(icon: Icons.logout, iconColor: Colors.red, title: 'Đăng xuất', isDestructive: true, onTap: onLogoutTap),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B))),
    );
  }
}
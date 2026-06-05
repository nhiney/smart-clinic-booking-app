import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'admin_setting_tile.dart';

class AdminSettingsView extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const AdminSettingsView({
    super.key,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                  child: Text(
                    (user?.name ?? 'A').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Quản trị viên',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'admin@icare.com',
                        style: const TextStyle(
                          fontSize: 14, 
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'QUẢN LÝ HỆ THỐNG',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Column(
            children: [
              AdminSettingTile(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF2563EB),
                title: 'Thông tin tài khoản Admin',
                subtitle: 'Cập nhật mật khẩu và hồ sơ cá nhân',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              AdminSettingTile(
                icon: Icons.notifications_none_rounded,
                iconColor: Colors.amber.shade700,
                title: 'Cấu hình thông báo',
                subtitle: 'Quản lý thông báo đẩy và nhắc lịch',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              AdminSettingTile(
                icon: Icons.security_rounded,
                iconColor: Colors.green.shade600,
                title: 'Bảo mật & Quyền truy cập',
                subtitle: 'Phân quyền và nhật ký hoạt động',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'ỨNG DỤNG & HỖ TRỢ',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Column(
            children: [
              AdminSettingTile(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.teal,
                title: 'Thông tin phiên bản',
                subtitle: 'Phiên bản hiện tại: v1.0.0 (iCare Pro)',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: AdminSettingTile(
            icon: Icons.logout_rounded,
            iconColor: Colors.red,
            title: 'Đăng xuất tài khoản',
            isDestructive: true,
            onTap: onLogoutTap,
          ),
        ),
      ],
    );
  }
}
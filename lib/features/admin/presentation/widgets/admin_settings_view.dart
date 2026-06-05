import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                onTap: () => _showAccountInfo(context),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              AdminSettingTile(
                icon: Icons.notifications_none_rounded,
                iconColor: Colors.amber.shade700,
                title: 'Cấu hình thông báo',
                subtitle: 'Quản lý thông báo đẩy và nhắc lịch',
                onTap: () => context.push('/notifications/settings'),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              AdminSettingTile(
                icon: Icons.security_rounded,
                iconColor: Colors.green.shade600,
                title: 'Bảo mật & Quyền truy cập',
                subtitle: 'Phân quyền và nhật ký hoạt động',
                onTap: () => _showSecurityInfo(context),
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
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'iCare Pro — Quản trị',
                  applicationVersion: 'v1.0.0',
                  children: const [Text('Hệ thống quản lý phòng khám thông minh ICare.')],
                ),
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

  void _showAccountInfo(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thông tin tài khoản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user?.email ?? '—'}'),
            const SizedBox(height: 8),
            Text('UID: ${user?.uid ?? '—'}'),
            const SizedBox(height: 8),
            Text('Tên hiển thị: ${user?.displayName ?? 'Quản trị viên'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = user?.email;
              Navigator.pop(context);
              if (email != null) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi email đổi mật khẩu.')),
                  );
                }
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showSecurityInfo(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bảo mật & Quyền truy cập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tài khoản: ${user?.email ?? '—'}'),
            const SizedBox(height: 8),
            const Text('Vai trò: Quản trị viên (Admin)'),
            const SizedBox(height: 8),
            Text('Email đã xác thực: ${user?.emailVerified == true ? 'Có' : 'Chưa'}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}
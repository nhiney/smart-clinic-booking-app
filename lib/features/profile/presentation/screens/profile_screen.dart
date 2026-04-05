import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../controllers/profile_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Hồ sơ cá nhân")),
      body: Consumer<AuthController>(
        builder: (_, auth, __) {
          final user = auth.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar + Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          (user?.name != null && user!.name.isNotEmpty ? user.name : 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'Người dùng',
                        style: AppTextStyles.heading2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? '',
                        style: AppTextStyles.body.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info cards
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: "Email",
                  value: (user?.email == null || user!.email.isEmpty) ? 'Chưa cập nhật' : user.email,
                  onTap: () => _showEditEmailDialog(context, user),
                  trailing: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                ),
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  title: "Số điện thoại",
                  value: user?.phone ?? 'Chưa cập nhật',
                ),
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: "Vai trò",
                  value: user?.role == 'patient' ? 'Bệnh nhân' : user?.role ?? '',
                ),
                const SizedBox(height: 24),

                // Menu items
                _buildMenuItem(
                  icon: Icons.history,
                  title: "Lịch sử khám bệnh",
                  onTap: () => Navigator.pushNamed(context, '/appointments'),
                ),
                _buildMenuItem(
                  icon: Icons.folder_outlined,
                  title: "Hồ sơ bệnh án",
                  onTap: () => Navigator.pushNamed(context, '/medical-records'),
                ),
                _buildMenuItem(
                  icon: Icons.medication_outlined,
                  title: "Nhắc uống thuốc",
                  onTap: () => Navigator.pushNamed(context, '/medication'),
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      "Đăng xuất",
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.caption),
                  Text(value, style: AppTextStyles.body),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context, UserEntity? user) {
    if (user == null) return;
    final emailController = TextEditingController(text: user.email);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cập nhật Email"),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: "Nhập email của bạn",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email không hợp lệ")),
                );
                return;
              }
              
              Navigator.pop(ctx);
              final profileController = context.read<ProfileController>();
              final authController = context.read<AuthController>();
              
              final updatedUser = UserEntity(
                id: user.id,
                email: newEmail,
                name: user.name,
                phone: user.phone,
                role: user.role,
                avatarUrl: user.avatarUrl,
                createdAt: user.createdAt,
              );
              
              final success = await profileController.updateProfile(updatedUser);
              if (success && context.mounted) {
                authController.updateUser(updatedUser); // Update session
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cập nhật email thành công")),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(profileController.errorMessage ?? "Lỗi cập nhật")),
                );
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

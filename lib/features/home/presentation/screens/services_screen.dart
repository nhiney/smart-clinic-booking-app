import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/quick_actions_grid.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/extensions/context_extension.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24),
            sliver: SliverToBoxAdapter(
              child: QuickActionsGrid(
                userRole: 'patient',
                onBookAppointment: () => context.push('/maps'),
                onViewAppointments: () => context.push('/appointments'),
                onMedicalRecords: () => context.push('/medical-records'),
                onPrescriptions: () => context.push('/prescriptions'),
                onContactSupport: () => context.push('/support'),
                onVoiceAssistant: () => context.push('/ai/voice-assistant'),
                onInpatientAdmission: () => context.push('/admission/registration/user_id'),
                onNotificationSettings: () => context.push('/notifications/settings'),
                onPricing: () => context.push('/transactions'),
                onSurveys: () => context.push('/surveys'),
                onProfile: () => context.push('/profile/patient'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, 'Tiện ích bổ sung'),
                const SizedBox(height: 16),
                _buildServiceTile(
                  context,
                  icon: Icons.local_pharmacy_outlined,
                  title: 'Mua thuốc online',
                  subtitle: 'Đặt mua thuốc từ đơn thuốc của bác sĩ',
                  onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Mua thuốc online')}'),
                ),
                _buildServiceTile(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Bảo hiểm y tế',
                  subtitle: 'Tra cứu và quản lý thẻ BHYT',
                  onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Bảo hiểm y tế')}'),
                ),
                _buildServiceTile(
                  context,
                  icon: Icons.history_edu_outlined,
                  title: 'Cẩm nang sức khỏe',
                  subtitle: 'Kiến thức y khoa hữu ích từ chuyên gia',
                  onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Cẩm nang sức khỏe')}'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Dịch vụ của tôi',
          style: context.textStyles.bodyBold.copyWith(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.grid_view_rounded, size: 100, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textStyles.bodyBold.copyWith(color: context.colors.primaryDark, fontSize: 18),
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.mRadius,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: context.radius.sRadius,
          ),
          child: Icon(icon, color: context.colors.primary, size: 24),
        ),
        title: Text(title, style: context.textStyles.bodyBold),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
        onTap: onTap,
      ),
    );
  }
}


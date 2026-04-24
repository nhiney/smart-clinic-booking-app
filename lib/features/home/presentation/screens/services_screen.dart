import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/quick_actions_grid.dart';
import '../../../../core/theme/colors/app_colors.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tất cả chức năng',
          style: TextStyle(color: Color(0xFF0D62A2), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            QuickActionsGrid(
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
            const SizedBox(height: 32),
            _buildExtraServices(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraServices(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích bổ sung',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D62A2)),
          ),
          const SizedBox(height: 16),
          _buildServiceTile(
            icon: Icons.local_pharmacy_outlined,
            title: 'Mua thuốc online',
            subtitle: 'Đặt mua thuốc từ đơn thuốc của bác sĩ',
            onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Mua thuốc online')}'),
          ),
          _buildServiceTile(
            icon: Icons.volunteer_activism_outlined,
            title: 'Bảo hiểm y tế',
            subtitle: 'Tra cứu và quản lý thẻ BHYT',
            onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Bảo hiểm y tế')}'),
          ),
          _buildServiceTile(
            icon: Icons.history_edu_outlined,
            title: 'Cẩm nang sức khỏe',
            subtitle: 'Kiến thức y khoa hữu ích từ chuyên gia',
            onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Cẩm nang sức khỏe')}'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF0288D1)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

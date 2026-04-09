import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/doctor_controller.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<DoctorController>().fetchDoctorProfile(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DoctorController>();
    final auth = context.watch<AuthController>();
    final doctor = controller.currentDoctor;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Bảng điều khiển Bác sĩ', style: context.textStyles.heading3),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context, doctor, auth.currentUser?.name ?? ''),
                  const SizedBox(height: 24),
                  _buildStatCards(context),
                  const SizedBox(height: 24),
                  _buildResumeSection(context, controller),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic doctor, String name) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              child: Icon(Icons.person_rounded, size: 40, color: context.colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.textStyles.bodyBold.copyWith(fontSize: 20)),
                  Text(doctor?.specialty ?? 'Chưa cập nhật chuyên khoa', style: context.textStyles.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${doctor?.experience ?? 0} năm kinh nghiệm',
                      style: context.textStyles.bodySmall.copyWith(color: context.colors.primary, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_note_rounded, color: context.colors.primary),
              onPressed: () => _editProfile(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Row(
      children: [
        _statCard(context, 'Lịch hẹn', '12', Icons.calendar_today_rounded, Colors.blue),
        const SizedBox(width: 16),
        _statCard(context, 'Bệnh nhân', '45', Icons.people_alt_rounded, Colors.green),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              Text(value, style: context.textStyles.heading3.copyWith(color: color)),
              Text(title, style: context.textStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumeSection(BuildContext context, DoctorController controller) {
    final hasResume = controller.currentDoctor?.resumePdfUrl.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hồ sơ chuyên môn (CVD/Resume)', style: context.textStyles.bodyBold),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.colors.border!)),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_rounded, color: hasResume ? Colors.red : context.colors.textHint),
            title: Text(hasResume ? 'Ly-lich-chuyen-mon.pdf' : 'Chưa có hồ sơ'),
            subtitle: Text(hasResume ? 'Đã tải lên' : 'Tải lên CV của bạn (PDF)'),
            onTap: () {
              if (hasResume) {
                _viewPdf(context, controller.currentDoctor!.resumePdfUrl);
              } else {
                controller.pickAndUploadResume(context.read<AuthController>().currentUser!.id);
              }
            },
            trailing: IconButton(
              icon: Icon(hasResume ? Icons.refresh_rounded : Icons.upload_file_rounded),
              onPressed: () => controller.pickAndUploadResume(context.read<AuthController>().currentUser!.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thao tác nhanh', style: context.textStyles.bodyBold),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _actionButton(context, 'Ca làm việc', Icons.timer_rounded),
            _actionButton(context, 'Hồ sơ bệnh án', Icons.description_rounded),
            _actionButton(context, 'Tin nhắn', Icons.chat_bubble_rounded),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border!),
      ),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary),
          const SizedBox(height: 8),
          Text(label, style: context.textStyles.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // Show edit dialog or navigate to edit screen
  }

  void _viewPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Lý lịch chuyên môn')),
          body: SfPdfViewer.network(url),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.password_rounded),
              title: const Text('Đổi mật khẩu'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Cập nhật Email'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                context.read<AuthController>().logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

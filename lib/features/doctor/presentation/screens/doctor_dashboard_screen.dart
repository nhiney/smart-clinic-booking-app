import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/doctor_controller.dart';
import '../../domain/entities/doctor_entity.dart';

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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (auth.currentUser != null) {
                  await controller.fetchDoctorProfile(auth.currentUser!.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, doctor, auth.currentUser?.name ?? 'Bác sĩ'),
                    const SizedBox(height: 16),
                    _buildBioSection(context, doctor),
                    const SizedBox(height: 24),
                    _buildStatCards(context, doctor),
                    const SizedBox(height: 24),
                    _buildResumeSection(context, controller),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, DoctorEntity? doctor, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.primary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[200],
              backgroundImage: (doctor?.imageUrl != null && doctor!.imageUrl.isNotEmpty)
                  ? NetworkImage(doctor.imageUrl)
                  : null,
              child: (doctor?.imageUrl == null || doctor!.imageUrl.isEmpty)
                  ? Icon(Icons.person_outline_rounded, size: 35, color: context.colors.primary)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor?.name ?? name,
                  style: context.textStyles.heading3.copyWith(color: Colors.white),
                ),
                Text(
                  doctor?.specialty ?? 'Chuyên khoa chưa cập nhật',
                  style: context.textStyles.bodySmall.copyWith(color: Colors.white.withAlpha(200)),
                ),
                if (doctor?.hospital != null && doctor!.hospital.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor.hospital,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editProfile(context),
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(BuildContext context, DoctorEntity? doctor) {
    return Card(
      elevation: 0,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.border.withAlpha(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Tiểu sử & Chuyên môn', style: context.textStyles.bodyBold),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              doctor?.about != null && doctor!.about.isNotEmpty
                  ? doctor.about
                  : 'Hãy cập nhật giới thiệu bản thân để bệnh nhân biết thêm về bạn.',
              style: context.textStyles.bodySmall.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, DoctorEntity? doctor) {
    return Row(
      children: [
        _statCard(
          context,
          'Xếp hạng',
          '${doctor?.rating ?? 0.0}',
          Icons.star_rounded,
          Colors.orange,
        ),
        const SizedBox(width: 12),
        _statCard(
          context,
          'Kinh nghiệm',
          '${doctor?.experience ?? 0}+ năm',
          Icons.work_history_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _statCard(
          context,
          'Lịch hẹn',
          '12',
          Icons.event_available_rounded,
          Colors.green,
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.border.withAlpha(30)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: context.textStyles.bodyBold.copyWith(fontSize: 16)),
            Text(
              title,
              style: context.textStyles.bodySmall.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeSection(BuildContext context, DoctorController controller) {
    final doctor = controller.currentDoctor;
    final hasResume = doctor?.resumePdfUrl != null && doctor!.resumePdfUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hồ sơ năng lực (CV)', style: context.textStyles.bodyBold),
            if (!hasResume)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => controller.pickAndUploadResume(doctor!.id),
                icon: Icon(Icons.add_circle_outline_rounded, color: context.colors.primary, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.border.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (hasResume ? Colors.red : Colors.grey).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: hasResume ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasResume ? 'Ly_lich_chuyen_mon.pdf' : 'Chưa cập nhật CV',
                      style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hasResume ? 'Dùng để chứng minh năng lực' : 'Vui lòng tải lên file PDF',
                      style: context.textStyles.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (hasResume) ...[
                IconButton(
                  onPressed: () => _viewPdf(context, doctor!.resumePdfUrl),
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                ),
                IconButton(
                  onPressed: () => controller.pickAndUploadResume(doctor!.id),
                  icon: const Icon(Icons.file_upload_outlined, size: 20),
                ),
              ] else
                TextButton(
                  onPressed: () => controller.pickAndUploadResume(doctor!.id),
                  child: const Text('Tải lên'),
                ),
            ],
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickActionButton(context, 'Lịch hẹn', Icons.calendar_month_rounded, Colors.blue),
            _quickActionButton(context, 'Hồ sơ', Icons.assignment_ind_rounded, Colors.purple),
            _quickActionButton(context, 'Tin nhắn', Icons.forum_rounded, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _quickActionButton(BuildContext context, String label, IconData icon, Color color) {
    final size = (MediaQuery.of(context).size.width - 64) / 3;
    return Container(
      width: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border.withAlpha(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: context.textStyles.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final controller = context.read<DoctorController>();
    final doctor = controller.currentDoctor;
    if (doctor == null) return;

    final specialtyController = TextEditingController(text: doctor.specialty);
    final expController = TextEditingController(text: doctor.experience.toString());
    final bioController = TextEditingController(text: doctor.about);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Chỉnh sửa hồ sơ', style: context.textStyles.heading3),
              const SizedBox(height: 24),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Chuyên khoa',
                  prefixIcon: Icon(Icons.medical_information_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số năm kinh nghiệm',
                  prefixIcon: Icon(Icons.history_edu_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Tiểu sử / Giới thiệu',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = DoctorEntity(
                      id: doctor.id,
                      name: doctor.name,
                      specialty: specialtyController.text,
                      experience: int.tryParse(expController.text) ?? doctor.experience,
                      about: bioController.text,
                      hospital: doctor.hospital,
                      phone: doctor.phone,
                      resumePdfUrl: doctor.resumePdfUrl,
                      departmentId: doctor.departmentId,
                    );
                    await controller.updateProfile(updated);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Cập nhật hồ sơ'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Tài khoản cá nhân'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded),
              title: const Text('Đổi mật khẩu'),
              onTap: () => Navigator.pop(context),
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

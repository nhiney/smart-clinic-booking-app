import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/record_version.dart';

class MedicalRecordDetailScreen extends ConsumerStatefulWidget {
  final MedicalRecordEntity record;
  const MedicalRecordDetailScreen({super.key, required this.record});

  @override
  ConsumerState<MedicalRecordDetailScreen> createState() => _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends ConsumerState<MedicalRecordDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(medicalRecordControllerProvider.notifier).loadAttachments(widget.record.id);
    });
  }

  Future<void> _pickAndUpload() async {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'dcm'],
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    final success = await ref.read(medicalRecordControllerProvider.notifier).uploadFile(
          recordId: widget.record.id,
          patientId: auth.currentUser?.id ?? '',
          file: File(picked.path!),
          fileName: picked.name,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Tải lên tệp thành công' : 'Tải lên thất bại'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showVersionHistory() async {
    await ref.read(medicalRecordControllerProvider.notifier).loadVersions(widget.record.id);
    if (!mounted) return;
    final versions = ref.read(medicalRecordControllerProvider).versions[widget.record.id] ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _VersionHistorySheet(versions: versions),
    );
  }

  void _showShareDialog() {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.share_rounded, color: context.colors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Chia sẻ hồ sơ', style: context.textStyles.heading3),
                ],
              ),
              const SizedBox(height: 20),
              Text('Nhập ID người dùng muốn chia sẻ:', style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'ID người dùng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Chia sẻ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final share = await ref.read(medicalRecordControllerProvider.notifier).shareRecord(
                          recordId: widget.record.id,
                          ownerId: auth.currentUser?.id ?? '',
                          sharedWithId: controller.text.trim(),
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(share != null ? 'Chia sẻ hồ sơ thành công' : 'Chia sẻ thất bại')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordControllerProvider);
    final attachments = state.attachments[widget.record.id] ?? [];
    final record = widget.record;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: BrandedAppBar(
        title: 'Chi tiết hồ sơ',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: context.colors.primary),
            onPressed: _showShareDialog,
            tooltip: 'Chia sẻ',
          ),
          IconButton(
            icon: Icon(Icons.history_rounded, color: context.colors.primary),
            onPressed: _showVersionHistory,
            tooltip: 'Lịch sử',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(record),
            SizedBox(height: context.spacing.l),
            if (record.symptoms?.isNotEmpty == true) ...[
              _buildSection(
                icon: Icons.sick_rounded,
                title: 'Triệu chứng',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: record.symptoms!
                      .map((s) => Chip(
                            label: Text(s, style: TextStyle(fontSize: 12, color: context.colors.primary)),
                            backgroundColor: context.colors.primary.withValues(alpha: 0.08),
                            side: BorderSide(color: context.colors.primary.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: context.spacing.l),
            ],
            _buildSection(
              icon: Icons.medical_information_rounded,
              title: 'Chẩn đoán',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.primary.withValues(alpha: 0.15)),
                ),
                child: Text(record.diagnosis, style: context.textStyles.body.copyWith(height: 1.5)),
              ),
            ),
            SizedBox(height: context.spacing.l),
            _buildSection(
              icon: Icons.medication_rounded,
              title: 'Đơn thuốc / Điều trị',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                ),
                child: Text(record.prescription, style: context.textStyles.body.copyWith(height: 1.5)),
              ),
            ),
            if (record.notes?.isNotEmpty == true) ...[
              SizedBox(height: context.spacing.l),
              _buildSection(
                icon: Icons.notes_rounded,
                title: 'Ghi chú bác sĩ',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    record.notes!,
                    style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, height: 1.5, color: context.colors.textSecondary),
                  ),
                ),
              ),
            ],
            SizedBox(height: context.spacing.l),
            _buildAttachmentSection(attachments, state),
            SizedBox(height: context.spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(MedicalRecordEntity record) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, context.colors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd/MM/yyyy', 'vi').format(record.createdAt),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#${record.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person_rounded, color: context.colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bác sĩ điều trị', style: context.textStyles.caption.copyWith(color: context.colors.textHint)),
                    Text('Dr. ${record.doctor}', style: context.textStyles.bodySmall.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(title, style: context.textStyles.bodyBold),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildAttachmentSection(List<Attachment> attachments, MedicalRecordState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file_rounded, size: 18, color: context.colors.primary),
                const SizedBox(width: 8),
                Text('Tệp đính kèm', style: context.textStyles.bodyBold),
              ],
            ),
            TextButton.icon(
              onPressed: _pickAndUpload,
              icon: Icon(Icons.upload_file_rounded, size: 16, color: context.colors.primary),
              label: Text('Tải lên', style: TextStyle(color: context.colors.primary, fontSize: 13)),
            ),
          ],
        ),
        if (state.isUploading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(value: state.uploadProgress),
          const SizedBox(height: 4),
          Text('Đang tải lên... ${(state.uploadProgress * 100).toInt()}%', style: context.textStyles.caption),
        ],
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.divider.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 32, color: context.colors.textHint),
                const SizedBox(height: 8),
                Text('Chưa có tệp đính kèm', style: context.textStyles.caption.copyWith(color: context.colors.textHint)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _AttachmentTile(attachment: attachments[i]),
          ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final Attachment attachment;
  const _AttachmentTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(attachment.fileType);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final url = Uri.parse(attachment.downloadUrl);
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attachment.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    '${attachment.fileType} · ${DateFormat('dd/MM/yyyy').format(attachment.uploadedAt)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return (Icons.picture_as_pdf_rounded, Colors.redAccent);
      case 'DCM':
        return (Icons.medical_information_rounded, Colors.purple);
      default:
        return (Icons.image_rounded, Colors.blueAccent);
    }
  }
}

class _VersionHistorySheet extends StatelessWidget {
  final List<RecordVersion> versions;
  const _VersionHistorySheet({required this.versions});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 22),
                const SizedBox(width: 8),
                const Text('Lịch sử phiên bản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            if (versions.isEmpty)
              const Expanded(child: Center(child: Text('Không có lịch sử phiên bản')))
            else
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: versions.length,
                  itemBuilder: (_, i) {
                    final v = versions[i];
                    final isCurrent = i == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.blue.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isCurrent ? Colors.blue : Colors.grey[200],
                            child: Text(
                              'v${v.versionNumber}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.changeNote.isEmpty ? 'Phiên bản ${v.versionNumber}' : v.changeNote,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isCurrent ? Colors.blue[700] : null),
                                ),
                                Text(DateFormat('dd/MM/yyyy HH:mm').format(v.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Hiện tại', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/record_version.dart';
import '../../domain/entities/record_share.dart';

class MedicalRecordScreen extends ConsumerStatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  ConsumerState<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends ConsumerState<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRecords());
  }

  void _refreshRecords() {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    if (auth.currentUser != null) {
      ref.read(medicalRecordControllerProvider.notifier).fetchRecords(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordControllerProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: 'Hồ sơ y tế',
        showBackButton: true,
      ),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 3)
          : state.records.isEmpty
              ? const EmptyStateWidget(
                  title: 'Chưa có hồ sơ y tế.',
                  icon: Icons.medical_services_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () async => _refreshRecords(),
                  child: _buildTimeline(state.records),
                ),
    );
  }

  Widget _buildTimeline(List<MedicalRecordEntity> records) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.l, vertical: context.spacing.xl),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineIndicator(isFirst: index == 0, isLast: index == records.length - 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.xl),
                  child: _RecordCard(record: record),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineIndicator extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  const _TimelineIndicator({required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Container(width: 2, height: 12, color: isFirst ? Colors.transparent : context.colors.divider.withOpacity(0.5)),
          Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.colors.divider.withOpacity(0.5), context.colors.divider.withOpacity(0.1)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordCard extends ConsumerStatefulWidget {
  final MedicalRecordEntity record;
  const _RecordCard({required this.record});

  @override
  ConsumerState<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends ConsumerState<_RecordCard> {
  bool _attachmentsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(medicalRecordControllerProvider.notifier).loadAttachments(widget.record.id);
      setState(() => _attachmentsLoaded = true);
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
        SnackBar(content: Text(success ? 'Tải lên tệp thành công' : 'Tải lên thất bại'), backgroundColor: success ? Colors.green : Colors.red),
      );
    }
  }

  void _showVersionHistory() async {
    await ref.read(medicalRecordControllerProvider.notifier).loadVersions(widget.record.id);
    if (!mounted) return;
    final versions = ref.read(medicalRecordControllerProvider).versions[widget.record.id] ?? [];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _VersionHistorySheet(versions: versions),
    );
  }

  void _showShareDialog() {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chia sẻ hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập ID người dùng muốn chia sẻ:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'ID người dùng', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
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
            child: const Text('Chia sẻ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordControllerProvider);
    final attachments = state.attachments[widget.record.id] ?? [];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorRow(),
                const SizedBox(height: 12),
                Text(widget.record.diagnosis, style: context.textStyles.heading3.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.medication_rounded, size: 14, color: context.colors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.record.prescription,
                        style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (widget.record.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(12)),
                    child: Text(widget.record.notes!, style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: context.colors.textSecondary)),
                  ),
                ],
                const SizedBox(height: 16),
                if (state.isUploading) ...[
                  LinearProgressIndicator(value: state.uploadProgress),
                  const SizedBox(height: 8),
                  Text('Đang tải lên... ${(state.uploadProgress * 100).toInt()}%', style: context.textStyles.caption),
                ],
                _buildAttachmentSection(attachments),
                const SizedBox(height: 12),
                _buildActionRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: context.colors.divider.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded, size: 16, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(DateFormat('dd/MM/yyyy').format(widget.record.createdAt), style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          Text('#${widget.record.id.substring(0, 8).toUpperCase()}', style: context.textStyles.caption.copyWith(color: context.colors.textHint, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildDoctorRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: context.colors.primary.withOpacity(0.1),
          child: Icon(Icons.person_rounded, size: 14, color: context.colors.primary),
        ),
        const SizedBox(width: 8),
        Text('Dr. ${widget.record.doctor}', style: context.textStyles.bodySmall.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildAttachmentSection(List<Attachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TỆP ĐÍNH KÈM', style: context.textStyles.caption.copyWith(color: context.colors.textHint, fontSize: 10, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: _pickAndUpload,
              child: Row(
                children: [
                  Icon(Icons.upload_file_rounded, size: 14, color: context.colors.primary),
                  const SizedBox(width: 4),
                  Text('Tải lên', style: context.textStyles.caption.copyWith(color: context.colors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attachments.isEmpty)
          Text('Không có tệp đính kèm', style: context.textStyles.caption.copyWith(color: context.colors.textHint))
        else
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _AttachmentCard(attachment: attachments[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showVersionHistory,
            icon: const Icon(Icons.history_rounded, size: 16),
            label: const Text('Lịch sử', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: context.colors.primary.withOpacity(0.5)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showShareDialog,
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Chia sẻ', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: context.colors.primary.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final Attachment attachment;
  const _AttachmentCard({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(attachment.fileType);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(attachment.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(attachment.fileType, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch sử phiên bản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (versions.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Không tìm thấy phiên bản nào'))
          else
            ...versions.map((v) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    child: Text('v${v.versionNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blue)),
                  ),
                  title: Text(v.changeNote.isEmpty ? 'Phiên bản ${v.versionNumber}' : v.changeNote),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(v.createdAt)),
                  dense: true,
                )),
        ],
      ),
    );
  }
}

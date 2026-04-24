import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRecords());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshRecords() {
    final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
    if (auth.currentUser != null) {
      ref.read(medicalRecordControllerProvider.notifier).fetchRecords(auth.currentUser!.id);
    }
  }

  List<MedicalRecordEntity> _filtered(List<MedicalRecordEntity> records) {
    if (_searchQuery.isEmpty) return records;
    final q = _searchQuery.toLowerCase();
    return records.where((r) =>
        r.diagnosis.toLowerCase().contains(q) ||
        r.doctor.toLowerCase().contains(q) ||
        (r.prescription.toLowerCase().contains(q))).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordControllerProvider);
    final filtered = _filtered(state.records);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: 'Hồ sơ y tế',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/medical-records/add'),
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm hồ sơ'),
      ),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 3)
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget(
                          title: _searchQuery.isEmpty ? 'Chưa có hồ sơ y tế.' : 'Không tìm thấy kết quả.',
                          icon: Icons.medical_services_outlined,
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _refreshRecords(),
                          child: _buildTimeline(filtered),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.spacing.l, context.spacing.m, context.spacing.l, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: 'Tìm chẩn đoán, bác sĩ...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTimeline(List<MedicalRecordEntity> records) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(context.spacing.l, context.spacing.m, context.spacing.l, 100),
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
                  padding: EdgeInsets.only(bottom: context.spacing.l),
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
          Container(width: 2, height: 12, color: isFirst ? Colors.transparent : context.colors.divider.withValues(alpha: 0.5)),
          Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: context.colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
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
                    colors: [context.colors.divider.withValues(alpha: 0.5), context.colors.divider.withValues(alpha: 0.1)],
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

    return GestureDetector(
      onTap: () => context.push('/medical-records/detail', extra: widget.record),
      child: AppCard(
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
                  Text(widget.record.diagnosis, style: context.textStyles.heading3.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.medication_rounded, size: 14, color: context.colors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.record.prescription,
                          style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (widget.record.symptoms?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.record.symptoms!.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 11, color: context.colors.primary)),
                          )).toList(),
                    ),
                  ],
                  if (widget.record.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(10)),
                      child: Text(widget.record.notes!, style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: context.colors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (state.isUploading) ...[
                    LinearProgressIndicator(value: state.uploadProgress),
                    const SizedBox(height: 6),
                    Text('Đang tải lên... ${(state.uploadProgress * 100).toInt()}%', style: context.textStyles.caption),
                  ],
                  _buildAttachmentRow(attachments),
                  const SizedBox(height: 10),
                  _buildActionRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: context.colors.divider.withValues(alpha: 0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_rounded, size: 14, color: context.colors.primary),
              const SizedBox(width: 6),
              Text(DateFormat('dd/MM/yyyy').format(widget.record.createdAt), style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          Row(
            children: [
              Text('#${widget.record.id.substring(0, 8).toUpperCase()}', style: context.textStyles.caption.copyWith(color: context.colors.textHint, letterSpacing: 1)),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 16, color: context.colors.textHint),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorRow() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: context.colors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person_rounded, size: 14, color: context.colors.primary),
        ),
        const SizedBox(width: 8),
        Text('Dr. ${widget.record.doctor}', style: context.textStyles.bodySmall.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildAttachmentRow(List<Attachment> attachments) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.attach_file_rounded, size: 13, color: context.colors.textHint),
        const SizedBox(width: 4),
        Text('${attachments.length} tệp đính kèm', style: context.textStyles.caption.copyWith(color: context.colors.textHint)),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showVersionHistory,
            icon: const Icon(Icons.history_rounded, size: 14),
            label: const Text('Lịch sử', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: context.colors.primary.withValues(alpha: 0.4)),
              foregroundColor: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickAndUpload,
            icon: const Icon(Icons.upload_file_rounded, size: 14),
            label: const Text('Tải lên', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: context.colors.primary.withValues(alpha: 0.4)),
              foregroundColor: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showShareDialog,
            icon: const Icon(Icons.share_rounded, size: 14),
            label: const Text('Chia sẻ', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: context.colors.primary.withValues(alpha: 0.4)),
              foregroundColor: context.colors.primary,
            ),
          ),
        ),
      ],
    );
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/entities/attachment.dart';
import '../bloc/medical_record_bloc.dart';
import '../bloc/medical_record_event.dart';
import '../bloc/medical_record_state.dart';

class RecordDetailScreen extends StatelessWidget {
  final MedicalRecord record;

  const RecordDetailScreen({super.key, required this.record});

  void _pickAndUploadFile(BuildContext context) async {
    // TODO: Integrate file_picker or image_picker package here to get the file.
    // For now, this is a placeholder for the logic before dispatching the event.
    
    // Example logic once file is picked:
    // final result = await FilePicker.platform.pickFiles();
    // if (result != null) {
    //   final file = File(result.files.single.path!);
    //   final fileName = result.files.single.name;
    //   context.read<MedicalRecordBloc>().add(UploadAttachmentEvent(
    //     file: file,
    //     recordId: record.id,
    //     patientId: record.patientId,
    //     fileName: fileName,
    //   ));
    // }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chọn tệp đang được tích hợp...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicalRecordBloc, MedicalRecordState>(
      listener: (context, state) {
        if (state is AttachmentUploadInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang tải file lên...'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is AttachmentUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải file lên thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AttachmentUploadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Chi tiết hồ sơ'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildDiagnosisSection(),
              const SizedBox(height: 24),
              _buildAttachmentsSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: _buildUploadButton(context),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Ngày khám', DateFormat('dd/MM/yyyy').format(record.createdAt)),
          const Divider(height: 32),
          _buildInfoRow('Bác sĩ', record.doctorId.isEmpty ? 'Chưa rõ' : record.doctorId),
          const Divider(height: 32),
          _buildInfoRow('Loại hồ sơ', record.type.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chẩn đoán & Ghi chú',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.diagnosis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  record.notes,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tài liệu đính kèm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (record.attachments.isEmpty)
          const Text(
            'Chưa có tài liệu nào.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.attachments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attachment = record.attachments[index];
              return _buildAttachmentTile(attachment);
            },
          ),
      ],
    );
  }

  Widget _buildAttachmentTile(Attachment attachment) {
    IconData icon;
    Color color;
    
    if (attachment.fileType.contains('pdf')) {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (['jpg', 'jpeg', 'png'].contains(attachment.fileType.toLowerCase())) {
      icon = Icons.image_rounded;
      color = Colors.blue;
    } else {
      icon = Icons.insert_drive_file_rounded;
      color = AppColors.textSecondary;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.download_rounded, color: AppColors.primary),
        onTap: () async {
          final url = Uri.parse(attachment.downloadUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _pickAndUploadFile(context),
          icon: const Icon(Icons.cloud_upload_rounded),
          label: const Text(
            'Tải kết quả lên',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

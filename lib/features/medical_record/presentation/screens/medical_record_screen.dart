import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/entities/medical_record_entity.dart';

class MedicalRecordScreen extends ConsumerStatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  ConsumerState<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends ConsumerState<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
      if (auth.currentUser != null) {
        ref.read(medicalRecordControllerProvider.notifier).fetchRecords(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: "Hồ sơ khám bệnh"),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 3)
          : state.records.isEmpty
              ? const EmptyStateWidget(
                  title: "Bạn chưa có hồ sơ khám bệnh nào.",
                  icon: Icons.medical_services_outlined,
                )
              : _buildTimeline(state.records),
    );
  }

  Widget _buildTimeline(List<MedicalRecordEntity> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return IntrinsicHeight(
          child: Row(
            children: [
              _buildTimelineIndicator(index == records.length - 1),
              Expanded(child: _buildRecordCard(record)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineIndicator(bool isLast) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primarySurface, width: 4),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecordEntity record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${record.date.day}/${record.date.month}/${record.date.year}",
                style: AppTextStyles.bodySmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "BS. ${record.doctor}",
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(record.diagnosis, style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          Text("Đơn thuốc: ${record.prescription}", style: AppTextStyles.body),
          const SizedBox(height: 12),
          _buildAttachments(record),
          if (record.notes != null) ...[
            const SizedBox(height: 8),
            Text("Ghi chú: ${record.notes}", style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachments(MedicalRecordEntity record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tài liệu đính kèm (PDF, X-ray):", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            _fileIcon(Icons.picture_as_pdf, "KetQua.pdf", Colors.redAccent),
            const SizedBox(width: 12),
            _fileIcon(Icons.image, "X-Ray.jpg", Colors.blueAccent),
            const SizedBox(width: 12),
            _addFileButton(),
          ],
        ),
      ],
    );
  }

  Widget _fileIcon(IconData icon, String name, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _addFileButton() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.grey, size: 24),
        ),
        const SizedBox(height: 4),
        const Text("Thêm", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

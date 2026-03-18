import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../controllers/medical_record_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'medical_record_detail_screen.dart';

class MedicalRecordListScreen extends StatefulWidget {
  const MedicalRecordListScreen({super.key});

  @override
  State<MedicalRecordListScreen> createState() => _MedicalRecordListScreenState();
}

class _MedicalRecordListScreenState extends State<MedicalRecordListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<MedicalRecordController>().loadRecords(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Hồ sơ bệnh án")),
      body: Consumer<MedicalRecordController>(
        builder: (_, controller, __) {
          if (controller.isLoading) {
            return const LoadingWidget(itemCount: 3);
          }
          if (controller.records.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.folder_open,
              title: "Chưa có hồ sơ bệnh án",
              subtitle: "Hồ sơ sẽ được tạo sau khi khám bệnh",
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.records.length,
            itemBuilder: (context, index) {
              final record = controller.records[index];
              return _buildRecordCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecordEntity record) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicalRecordDetailScreen(record: record),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.diagnosis, style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("BS. ${record.doctorName}", style: AppTextStyles.bodySmall),
                  Text(
                    DateFormat('dd/MM/yyyy').format(record.date),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

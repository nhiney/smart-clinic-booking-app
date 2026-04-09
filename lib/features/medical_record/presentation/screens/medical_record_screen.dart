import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/entities/medical_record_entity.dart';
import 'package:intl/intl.dart';

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
      _refreshRecords();
    });
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
      appBar: const BrandedAppBar(title: "Hồ sơ khám bệnh"),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 3)
          : state.records.isEmpty
              ? const EmptyStateWidget(
                  title: "Bạn chưa có hồ sơ khám bệnh nào.",
                  icon: Icons.medical_services_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _refreshRecords();
                  },
                  child: _buildTimeline(context, state.records),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add record logic
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<MedicalRecordEntity> records) {
    return ListView.builder(
      padding: EdgeInsets.all(context.spacing.l),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isLast = index == records.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineIndicator(context, isLast),
              Expanded(child: _buildRecordCard(context, record)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineIndicator(BuildContext context, bool isLast) {
    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: context.colors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 4),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: context.colors.divider,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, MedicalRecordEntity record) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.l),
      child: AppCard(
        padding: EdgeInsets.all(context.spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(record.createdAt),
                  style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: context.radius.sRadius,
                  ),
                  child: Text(
                    "BS. ${record.doctor}",
                    style: context.textStyles.caption.copyWith(
                      color: context.colors.primary, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.m),
            Text(
              record.diagnosis, 
              style: context.textStyles.bodyBold.copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: context.spacing.s),
            Text(
              "Đơn thuốc: ${record.prescription}", 
              style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
            ),
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              Divider(height: context.spacing.l, color: context.colors.divider),
              Text(
                "Ghi chú: ${record.notes}", 
                style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            SizedBox(height: context.spacing.m),
            _buildAttachments(context, record),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, MedicalRecordEntity record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tài liệu đính kèm (PDF, X-ray):", 
          style: context.textStyles.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _fileIcon(context, Icons.picture_as_pdf, "KetQua.pdf", Colors.redAccent),
              SizedBox(width: context.spacing.m),
              _fileIcon(context, Icons.image, "X-Ray.jpg", Colors.blueAccent),
              SizedBox(width: context.spacing.m),
              _addFileButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fileIcon(BuildContext context, IconData icon, String name, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.spacing.s),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), 
            borderRadius: context.radius.sRadius,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(name, style: context.textStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _addFileButton(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.spacing.s),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.divider),
            borderRadius: context.radius.sRadius,
          ),
          child: Icon(Icons.add, color: context.colors.textHint, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          "Thêm", 
          style: context.textStyles.caption.copyWith(fontSize: 10, color: context.colors.textHint),
        ),
      ],
    );
  }
}

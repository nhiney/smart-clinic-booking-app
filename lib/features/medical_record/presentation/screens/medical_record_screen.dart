import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
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
      padding: EdgeInsets.symmetric(horizontal: context.spacing.l, vertical: context.spacing.xl),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final isLast = index == records.length - 1;
        final isFirst = index == 0;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimelineIndicator(context, isFirst, isLast),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.xl),
                  child: _buildRecordCard(context, record),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineIndicator(BuildContext context, bool isFirst, bool isLast) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          Container(
            width: 2,
            height: 12,
            color: isFirst ? Colors.transparent : context.colors.divider.withValues(alpha: 0.5),
          ),
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
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
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
                    colors: [
                      context.colors.divider.withValues(alpha: 0.5),
                      context.colors.divider.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, MedicalRecordEntity record) {
    return AppCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Date and ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Icon(Icons.event_note_rounded, size: 16, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(record.createdAt),
                      style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  "#${record.id.substring(0, 8).toUpperCase()}",
                  style: context.textStyles.caption.copyWith(color: context.colors.textHint, letterSpacing: 1),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person_rounded, size: 14, color: context.colors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "BS. ${record.doctor}",
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  record.diagnosis, 
                  style: context.textStyles.heading3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.medication_rounded, size: 14, color: context.colors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.prescription, 
                        style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.notes!, 
                      style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: context.colors.textSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildAttachments(context, record),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, MedicalRecordEntity record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TÀI LIỆU ĐÍNH KÈM", 
              style: context.textStyles.caption.copyWith(
                color: context.colors.textHint,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "Xem tất cả",
                style: context.textStyles.caption.copyWith(
                  color: context.colors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _fileCard(context, Icons.picture_as_pdf_rounded, "Kết quả xét nghiệm", Colors.redAccent),
              const SizedBox(width: 12),
              _fileCard(context, Icons.image_rounded, "Phim X-Quang", Colors.blueAccent),
              const SizedBox(width: 12),
              _addFileButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fileCard(BuildContext context, IconData icon, String title, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "2.4 MB", 
            style: context.textStyles.caption.copyWith(fontSize: 10, color: context.colors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _addFileButton(BuildContext context) {
    return Container(
      width: 60,
      height: 75,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.divider, style: BorderStyle.none),
      ),
      child: Center(
        child: Icon(Icons.add_rounded, color: context.colors.textHint),
      ),
    );
  }
}

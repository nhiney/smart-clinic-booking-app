import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/shared/widgets/ai_suggestion_card.dart';
import 'package:smart_clinic_booking/shared/widgets/medication_card.dart';
import 'package:smart_clinic_booking/shared/widgets/patient_header_card.dart';
import 'package:smart_clinic_booking/shared/widgets/sticky_bottom_action_bar.dart';
import '../riverpod/clinical_providers.dart';

class TreatmentPlanScreen extends ConsumerStatefulWidget {
  final String encounterId;

  const TreatmentPlanScreen({
    super.key,
    required this.encounterId,
  });

  @override
  ConsumerState<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends ConsumerState<TreatmentPlanScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _didInitialize = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _sync(TreatmentPlanState state) {
    final plan = state.plan;
    if (plan == null || _didInitialize) {
      return;
    }
    _didInitialize = true;
    _notesController.text = plan.notes;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treatmentPlanControllerProvider(widget.encounterId));
    final controller = ref.read(treatmentPlanControllerProvider(widget.encounterId).notifier);
    _sync(state);

    if (state.isLoading || state.plan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final plan = state.plan!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: 'Kế hoạch điều trị',
        showBackButton: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.spacing.l,
          context.spacing.m,
          context.spacing.l,
          120,
        ),
        children: [
          PatientHeaderCard(
            fullName: plan.patientName,
            subtitle: '${plan.patientGender} • ${plan.patientAge} tuổi • ${plan.patientCode}',
            code: plan.encounterId,
            bloodGroup: plan.diagnosisSummary,
            weightLabel: plan.followUpDate == null ? 'N/A' : 'Hẹn ${DateFormat('dd/MM/yyyy').format(plan.followUpDate!)}',
            alertLabel: 'ICD ${plan.icdCodes.length}',
          ),
          const SizedBox(height: 18),
          Text(
            'THUỐC',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...plan.medications.map(
            (medication) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MedicationCard(medication: medication),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'XÉT NGHIỆM',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['CBC', 'HbA1C', 'Lipid Profile', 'ECG']
                .map(
                  (item) => FilterChip(
                    label: Text(item),
                    selected: plan.labTests.contains(item),
                    onSelected: (_) => controller.toggleLabTest(item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'CHẨN ĐOÁN HÌNH ẢNH',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['X-Ray', 'MRI', 'CT Scan']
                .map(
                  (item) => FilterChip(
                    label: Text(item),
                    selected: plan.imagingTests.contains(item),
                    onSelected: (_) => controller.toggleImagingTest(item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'TÁI KHÁM',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              plan.followUpDate == null ? 'Chưa chọn ngày' : DateFormat('dd/MM/yyyy').format(plan.followUpDate!),
              style: context.textStyles.subtitle,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: plan.followUpDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  controller.updateFollowUpDate(picked);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã cập nhật tái khám ${DateFormat('dd/MM/yyyy').format(picked)}')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'GHI CHÚ',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            onChanged: controller.updateNotes,
            decoration: const InputDecoration(
              hintText: 'Ghi chú cho kế hoạch điều trị',
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'AI ĐỀ XUẤT THÊM',
            style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: controller.generateMedicationSuggestions,
            icon: const Icon(Icons.auto_fix_high_rounded),
            label: const Text('AI gợi ý thuốc'),
          ),
          if (state.medicationSuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...state.medicationSuggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AISuggestionCard(
                  code: suggestion.name,
                  title: '${suggestion.dosage} • ${suggestion.frequency}',
                  confidence: suggestion.days,
                  onAdd: () => controller.addMedicationSuggestion(suggestion),
                ),
              ),
            ),
          ],
          if (plan.exportedPdfPath != null) ...[
            const SizedBox(height: 12),
            Text(
              'Đã lưu local: ${plan.exportedPdfPath}',
              style: context.textStyles.caption.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: StickyBottomActionBar(
        primaryLabel: 'Xuất PDF',
        onPrimaryTap: () async {
          await controller.exportPdf();
          if (!context.mounted) {
            return;
          }
          final exported = ref.read(treatmentPlanControllerProvider(widget.encounterId)).plan?.exportedPdfPath;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(exported == null ? 'Xuất PDF thất bại' : 'Đã lưu PDF: $exported')),
          );
        },
        isBusy: state.isExporting,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../shared/widgets/ai_suggestion_card.dart';
import '../../../../shared/widgets/diagnosis_chip.dart';
import '../../../../shared/widgets/patient_header_card.dart';
import '../../../../shared/widgets/soap_stepper.dart';
import '../../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../riverpod/clinical_providers.dart';

class ClinicalEncounterScreen extends ConsumerStatefulWidget {
  final String encounterId;

  const ClinicalEncounterScreen({
    super.key,
    required this.encounterId,
  });

  @override
  ConsumerState<ClinicalEncounterScreen> createState() => _ClinicalEncounterScreenState();
}

class _MedicationDraftControllers {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final TextEditingController timesController;
  final TextEditingController daysController;
  final TextEditingController notesController;

  _MedicationDraftControllers({
    String name = '',
    String dosage = '',
    String times = '1',
    String days = '7',
    String notes = '',
  })  : nameController = TextEditingController(text: name),
        dosageController = TextEditingController(text: dosage),
        timesController = TextEditingController(text: times),
        daysController = TextEditingController(text: days),
        notesController = TextEditingController(text: notes);

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    timesController.dispose();
    daysController.dispose();
    notesController.dispose();
  }

  MedicationDraft toDraft() {
    return MedicationDraft(
      name: nameController.text,
      dosage: dosageController.text,
      timesPerDay: int.tryParse(timesController.text) ?? 1,
      days: int.tryParse(daysController.text) ?? 7,
      notes: notesController.text,
    );
  }
}

class MedicationDraft {
  final String name;
  final String dosage;
  final int timesPerDay;
  final int days;
  final String notes;

  const MedicationDraft({
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.days,
    required this.notes,
  });
}

class _ClinicalEncounterScreenState extends ConsumerState<ClinicalEncounterScreen> {
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _icdController = TextEditingController();
  final _followUpController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  final List<_MedicationDraftControllers> _medicationControllers = [];

  bool _didInitialize = false;

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _notesController.dispose();
    _icdController.dispose();
    _followUpController.dispose();
    for (final item in _medicationControllers) {
      item.dispose();
    }
    _voiceService.dispose();
    super.dispose();
  }

  void _ensureInitialized(ClinicalEncounterState state) {
    final encounter = state.encounter;
    if (encounter == null || _didInitialize) {
      return;
    }
    _didInitialize = true;

    _subjectiveController.text = encounter.subjective;
    _objectiveController.text = encounter.objective;
    _assessmentController.text = encounter.assessment;
    _notesController.text = encounter.notes;
    _followUpController.text = encounter.followUpDate == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(encounter.followUpDate!);

    for (final item in _medicationControllers) {
      item.dispose();
    }
    _medicationControllers.clear();

    if (encounter.medications.isEmpty) {
      _medicationControllers.add(_MedicationDraftControllers());
      return;
    }

    for (final medication in encounter.medications) {
      _medicationControllers.add(
        _MedicationDraftControllers(
          name: medication.name,
          dosage: medication.dosage,
          times: medication.timesPerDay.toString(),
          days: medication.days.toString(),
          notes: medication.notes,
        ),
      );
    }
  }

  void _addMedicationEditor() {
    _medicationControllers.add(_MedicationDraftControllers());
    setState(() {});
  }

  String _formatElapsed(int elapsedSeconds) {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startVoiceInput(
    TextEditingController controller,
    VoidCallback onChanged,
  ) async {
    await _voiceService.startListening(
      onResult: (text) {
        controller.text = text;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        onChanged();
      },
      onListeningChange: (_) {},
      onError: (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  Widget _buildTextBlock({
    required String title,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool multiline = true,
    VoidCallback? onVoiceTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onVoiceTap,
                icon: const Icon(Icons.mic_none_rounded),
                tooltip: 'Voice input',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: multiline ? 4 : 1,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationEditor(
    int index,
    ClinicalEncounterController controller,
  ) {
    final item = _medicationControllers[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Thuốc ${index + 1}',
                  style: context.textStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _medicationControllers.length == 1
                    ? null
                    : () {
                        item.dispose();
                        _medicationControllers.removeAt(index);
                        controller.removeMedicationPlan(index);
                        setState(() {});
                      },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: item.nameController,
            decoration: const InputDecoration(hintText: 'Tên thuốc'),
            onChanged: (value) => controller.updateMedicationPlanField(index, name: value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: item.dosageController,
            decoration: const InputDecoration(hintText: 'Liều'),
            onChanged: (value) => controller.updateMedicationPlanField(index, dosage: value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.timesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Số lần/ngày'),
                  onChanged: (value) => controller.updateMedicationPlanField(
                    index,
                    timesPerDay: int.tryParse(value) ?? 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: item.daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Số ngày'),
                  onChanged: (value) => controller.updateMedicationPlanField(
                    index,
                    days: int.tryParse(value) ?? 7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: item.notesController,
            decoration: const InputDecoration(hintText: 'Ghi chú'),
            onChanged: (value) => controller.updateMedicationPlanField(index, notes: value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clinicalEncounterControllerProvider(widget.encounterId));
    final controller = ref.read(clinicalEncounterControllerProvider(widget.encounterId).notifier);
    _ensureInitialized(state);

    if (state.isLoading || state.patient == null || state.encounter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final patient = state.patient!;
    final encounter = state.encounter!;
    final currentStep = state.currentStep;
    final primaryLabel = currentStep == 0
        ? 'Tiếp tục bước O →'
        : currentStep == 1
            ? 'Tiếp tục bước A →'
            : currentStep == 2
                ? 'Tiếp tục bước P →'
                : 'Hoàn tất bệnh án';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: 'Khám lâm sàng SOAP',
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
            fullName: patient.fullName,
            subtitle: '${patient.gender} • ${patient.age}t • ${patient.code}',
            code: encounter.patientCode,
            bloodGroup: encounter.diagnosisBadge,
            weightLabel: encounter.visitTimeLabel,
            alertLabel: 'Lần khám ${encounter.visitCount}',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatElapsed(state.elapsedSeconds),
                      style: context.textStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: state.isAutoSaving ? context.colors.warning : context.colors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isAutoSaving ? 'Đang lưu...' : 'Tự động lưu',
                          style: context.textStyles.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      encounter.visitTimeLabel,
                      style: context.textStyles.subtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lần khám ${encounter.visitCount}',
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoapStepper(
            currentStep: currentStep,
            onStepTap: controller.setStep,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: encounter.icdCodes
                .map(
                  (code) => DiagnosisChip(
                    label: code,
                    onDelete: () => controller.removeIcdCode(code),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          if (currentStep == 0)
            _buildTextBlock(
              title: 'Triệu chứng chủ quan',
              hint: 'Nhập triệu chứng chủ quan',
              controller: _subjectiveController,
              onChanged: controller.updateSubjective,
              onVoiceTap: () => _startVoiceInput(
                _subjectiveController,
                () => controller.updateSubjective(_subjectiveController.text),
              ),
            ),
          if (currentStep == 1)
            _buildTextBlock(
              title: 'Khám thực thể',
              hint: 'Nhập kết quả khám thực thể',
              controller: _objectiveController,
              onChanged: controller.updateObjective,
              onVoiceTap: () => _startVoiceInput(
                _objectiveController,
                () => controller.updateObjective(_objectiveController.text),
              ),
            ),
          if (currentStep == 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Assessment',
                          style: context.textStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: controller.generateDiagnosisSuggestions,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('AI gợi ý'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _assessmentController,
                    maxLines: 3,
                    onChanged: controller.updateAssessment,
                    decoration: const InputDecoration(
                      hintText: 'Nhập chẩn đoán hiện tại',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _icdController,
                          decoration: const InputDecoration(
                            hintText: 'Thêm ICD-10',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          final code = _icdController.text.trim();
                          if (code.isEmpty) {
                            return;
                          }
                          controller.addIcdCode(code);
                          _icdController.clear();
                        },
                        child: const Text('Thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.diagnosisSuggestions.isNotEmpty) ...[
                    Text(
                      'AI ĐỀ XUẤT THÊM',
                      style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...state.diagnosisSuggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AISuggestionCard(
                          code: suggestion.code,
                          title: suggestion.name,
                          confidence: suggestion.confidence,
                          onAdd: () => controller.addIcdCode(suggestion.code),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (currentStep == 3)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Plan',
                          style: context.textStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: controller.generateMedicationSuggestions,
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: const Text('AI thuốc'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _medicationControllers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildMedicationEditor(index, controller),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        _addMedicationEditor();
                        controller.addMedicationPlan();
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Thêm thuốc'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Xét nghiệm',
                    style: context.textStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const ['CBC', 'HbA1C', 'Lipid', 'ECG']
                        .map(
                          (item) => FilterChip(
                            label: Text(item),
                            selected: encounter.labTests.contains(item),
                            onSelected: (_) => controller.toggleLabTest(item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chẩn đoán hình ảnh',
                    style: context.textStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const ['X-ray', 'MRI', 'CT']
                        .map(
                          (item) => FilterChip(
                            label: Text(item),
                            selected: encounter.imagingTests.contains(item),
                            onSelected: (_) => controller.toggleImagingTest(item),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hẹn tái khám',
                    style: context.textStyles.subtitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _followUpController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Chọn ngày tái khám',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: encounter.followUpDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            controller.updateFollowUpDate(date);
                            _followUpController.text = DateFormat('dd/MM/yyyy').format(date);
                          }
                        },
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    onChanged: controller.updateNotes,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú kế hoạch',
                    ),
                  ),
                  if (state.medicationSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'AI ĐỀ XUẤT THUỐC',
                      style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
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
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Cập nhật gần nhất: ${state.lastAutosaveAt == null ? 'chưa có' : DateFormat('HH:mm:ss').format(state.lastAutosaveAt!)}',
            style: context.textStyles.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: context.textStyles.caption.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: StickyBottomActionBar(
        primaryLabel: primaryLabel,
        onPrimaryTap: () async {
          if (currentStep < 3) {
            controller.nextStep();
            return;
          }
          await controller.completeEncounter();
          if (!context.mounted) {
            return;
          }
          context.go('/encounter/${widget.encounterId}/plan');
        },
        secondaryLabel: 'Lưu nháp',
        onSecondaryTap: () => controller.saveDraft(),
        isBusy: state.isSaving,
      ),
    );
  }
}

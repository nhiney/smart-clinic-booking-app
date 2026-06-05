import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../appointment/domain/entities/appointment_entity.dart';
import '../riverpod/examination_provider.dart';

/// Phiên khám — mở từ lịch hoặc thao tác nhanh "Khám".
/// Lưu chẩn đoán + đơn thuốc vào `medical_records` và đánh dấu lịch hẹn hoàn thành.
class DoctorExamineScreen extends ConsumerStatefulWidget {
  final dynamic appointment;
  const DoctorExamineScreen({super.key, this.appointment});

  @override
  ConsumerState<DoctorExamineScreen> createState() => _DoctorExamineScreenState();
}

class _DoctorExamineScreenState extends ConsumerState<DoctorExamineScreen> {
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppointmentEntity apt = widget.appointment as AppointmentEntity;
    final diagnosis = _diagnosisController.text.trim();
    if (diagnosis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập chẩn đoán trước khi lưu.')),
      );
      return;
    }

    await ref.read(examinationProvider.notifier).save(
          appointmentId: apt.id,
          patientId: apt.patientId,
          patientName: apt.patientName,
          diagnosis: diagnosis,
          prescription: _prescriptionController.text.trim(),
          notes: _notesController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(examinationProvider);
    if (state.isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu phiên khám và hoàn thành lịch hẹn.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${state.error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apt = widget.appointment;
    final isSaving = ref.watch(examinationProvider).isSaving;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.doctor_button_examine),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (apt == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Chọn bệnh nhân từ "Lịch hôm nay" hoặc tab Lịch hẹn, rồi nhấn Khám.',
                style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
              ),
            )
          else ...[
            Text(apt.patientName, style: context.textStyles.heading3),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.yMMMd().format(apt.dateTime)} · ${DateFormat.Hm().format(apt.dateTime)}',
              style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
            if (apt.specialty.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(apt.specialty, style: context.textStyles.bodySmall),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _diagnosisController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.doctor_diagnosis,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: context.colors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Đơn thuốc',
                hintText: 'VD: Paracetamol 500mg × 2 viên/ngày sau ăn, 5 ngày',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: context.colors.surface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                hintText: apt.notes.isNotEmpty ? apt.notes : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: context.colors.surface,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.doctor_send_prescription),
            ),
          ],
        ],
      ),
    );
  }
}

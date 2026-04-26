import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../appointment/domain/entities/appointment_entity.dart';



/// Phiên khám — mở từ lịch hoặc thao tác nhanh "Khám".
class DoctorExamineScreen extends StatefulWidget {
  const DoctorExamineScreen({super.key, this.appointment});

  final AppointmentEntity? appointment;

  @override
  State<DoctorExamineScreen> createState() => _DoctorExamineScreenState();
}

class _DoctorExamineScreenState extends State<DoctorExamineScreen> {
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apt = widget.appointment;

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
                color: context.colors.primary.withOpacity(0.08),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã lưu nháp phiên khám (demo).')),
                );
                Navigator.of(context).pop();
              },
              child: Text(l10n.doctor_send_prescription),
            ),
          ],
        ],
      ),
    );
  }
}

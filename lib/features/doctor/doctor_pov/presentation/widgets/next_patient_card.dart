import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/features/doctor/patient_pov/presentation/controllers/doctor_controller.dart';
import 'package:smart_clinic_booking/features/appointment/domain/entities/appointment_entity.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';

class NextPatientCard extends StatelessWidget {
  const NextPatientCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final upcoming = ctrl.todayAppointments
        .where((a) =>
            a.status == AppointmentStatuses.confirmed ||
            a.status == AppointmentStatuses.booked ||
            a.status == AppointmentStatuses.inQueue)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (upcoming.isEmpty) return const SizedBox.shrink();
    final next = upcoming.first;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF1D4ED8), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bệnh nhân tiếp theo',
                      style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(next.patientName,
                      style: context.textStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtTime(next.dateTime)} · ${next.specialty.isNotEmpty ? next.specialty : "Nội tổng quát"} · ${next.queueNumber}',
                    style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: next.priorityLevel == AppointmentPriorityLevels.emergency
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                next.priorityLevel == AppointmentPriorityLevels.emergency ? 'Khẩn' : 'Bình thường',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: next.priorityLevel == AppointmentPriorityLevels.emergency
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

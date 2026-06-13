import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/features/roles/doctor/patient_pov/presentation/controllers/doctor_controller.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final stats = ctrl.stats;
    final total = stats['today_total'] ?? 0;
    final waiting = stats['waiting'] ?? 0;
    final confirmed = stats['confirmed'] ?? 0;
    final done = (total - waiting - confirmed).clamp(0, total);
    final progress = total > 0 ? done / total : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.primary, context.colors.primary.withValues(alpha: 0.78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiến độ hôm nay',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('$done / $total ca',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Chip(label: 'Đang chờ', value: '$waiting', icon: Icons.hourglass_empty_rounded),
                const SizedBox(width: 10),
                _Chip(label: 'Xác nhận', value: '$confirmed', icon: Icons.check_circle_outline_rounded),
                const SizedBox(width: 10),
                _Chip(label: 'Đã khám', value: '$done', icon: Icons.task_alt_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Chip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

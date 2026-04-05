import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';

/// Section 3: Upcoming Appointment — next scheduled appointment with actions.
class UpcomingAppointmentCard extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final VoidCallback onViewAll;
  final VoidCallback onBook;
  final ValueChanged<AppointmentEntity> onCancel;
  final ValueChanged<AppointmentEntity> onReschedule;

  const UpcomingAppointmentCard({
    super.key,
    required this.appointments,
    required this.onViewAll,
    required this.onBook,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Lịch hẹn sắp tới', actionText: 'Xem tất cả', onAction: onViewAll),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: appointments.isEmpty
              ? _EmptyState(onBook: onBook)
              : _AppointmentItem(
                  appointment: appointments.first,
                  onCancel: () => onCancel(appointments.first),
                  onReschedule: () => onReschedule(appointments.first),
                ),
        ),
      ],
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const _AppointmentItem({
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                    ),
                    Text(
                      appointment.specialty,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: appointment.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                dateFormatter.format(appointment.dateTime),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                timeFormatter.format(appointment.dateTime),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Đổi lịch', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(status),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatStatus(String s) {
    switch (s) {
      case 'confirmed': return 'Đã xác nhận';
      case 'pending': return 'Chờ xác nhận';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return s;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBook;

  const _EmptyState({required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text('Chưa có lịch hẹn nào', style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text('Đặt lịch khám để được chăm sóc sức khỏe kịp thời',
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Đặt lịch ngay', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionTitle({required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.heading3)),
          TextButton(
            onPressed: onAction,
            child: Text(actionText, style: AppTextStyles.link.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

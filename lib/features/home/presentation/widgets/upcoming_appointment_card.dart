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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: appointment.status),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  dateFormatter.format(appointment.dateTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF455A64),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  timeFormatter.format(appointment.dateTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF455A64),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF607D8B),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Đổi lịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String s) {
    switch (s) {
      case 'confirmed': return const Color(0xFF4CAF50);
      case 'pending': return const Color(0xFFFF9800);
      case 'completed': return const Color(0xFF2196F3);
      case 'cancelled': return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  String _formatStatus(String s) {
    switch (s) {
      case 'confirmed': return 'Đã xác nhận';
      case 'pending': return 'Chờ';
      case 'completed': return 'Xong';
      case 'cancelled': return 'Hủy';
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

import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/features/appointment/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/extensions/context_extension.dart';

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
        _SectionTitle(
            title: 'Lịch hẹn sắp tới',
            actionText: 'Xem tất cả',
            onAction: onViewAll),
        const SizedBox(height: 16),
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
        color: context.colors.surface,
        borderRadius: context.radius.mRadius,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: context.colors.primary.withOpacity(0.05), width: 1.5),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: context.radius.sRadius,
                ),
                child: Icon(Icons.person_rounded, color: context.colors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: context.textStyles.bodyBold.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.specialty,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: appointment.status),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: context.radius.sRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: context.colors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  dateFormatter.format(appointment.dateTime),
                  style: context.textStyles.bodyBold.copyWith(fontSize: 15),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded, color: context.colors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  timeFormatter.format(appointment.dateTime),
                  style: context.textStyles.bodyBold.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.divider),
                    shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Hủy hẹn', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReschedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Đổi lịch', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final normalized = AppointmentStatuses.normalize(status);
    final color = _getStatusColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatStatus(normalized),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String s) {
    switch (s) {
      case AppointmentStatuses.confirmed:
      case AppointmentStatuses.checkedIn:
      case AppointmentStatuses.inQueue:
      case AppointmentStatuses.inConsultation:
      case AppointmentStatuses.postConsultation:
        return const Color(0xFF4CAF50);
      case AppointmentStatuses.pendingBooking:
      case AppointmentStatuses.booked:
      case AppointmentStatuses.rescheduled:
        return const Color(0xFFFF9800);
      case AppointmentStatuses.completed:
        return const Color(0xFF2196F3);
      case AppointmentStatuses.cancelled:
      case AppointmentStatuses.noShow:
      case AppointmentStatuses.noShowPending:
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String s) {
    switch (s) {
      case AppointmentStatuses.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatuses.pendingBooking:
        return 'Chờ xác nhận';
      case AppointmentStatuses.booked:
        return 'Đã đặt';
      case AppointmentStatuses.checkedIn:
        return 'Đã đến';
      case AppointmentStatuses.inQueue:
        return 'Đang chờ';
      case AppointmentStatuses.inConsultation:
        return 'Đang khám';
      case AppointmentStatuses.completed:
        return 'Hoàn thành';
      case AppointmentStatuses.cancelled:
        return 'Đã hủy';
      default:
        return s.toUpperCase();
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: context.radius.mRadius,
        border: Border.all(color: context.colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_rounded, size: 48, color: context.colors.primary.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text('Chưa có lịch hẹn', style: context.textStyles.bodyBold),
          const SizedBox(height: 8),
          Text(
            'Hãy đặt lịch khám để được chăm sóc sức khỏe tốt nhất',
            style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              elevation: 0,
            ),
            child: const Text('Đặt lịch ngay', style: TextStyle(fontWeight: FontWeight.bold)),
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
          Expanded(
            child: Text(
              title,
              style: context.textStyles.bodyBold.copyWith(fontSize: 18, color: context.colors.primaryDark),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: context.colors.primary),
            child: Row(
              children: [
                Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


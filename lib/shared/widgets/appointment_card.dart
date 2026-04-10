import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/typography/app_text_styles.dart';
import '../../features/appointment/domain/entities/appointment_entity.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
    this.onTap,
    this.onCancel,
  });

  Color _statusColor() {
    switch (AppointmentStatuses.normalize(status)) {
      case AppointmentStatuses.pendingBooking:
      case AppointmentStatuses.booked:
      case AppointmentStatuses.rescheduled:
        return AppColors.statusPending;
      case AppointmentStatuses.confirmed:
      case AppointmentStatuses.checkedIn:
      case AppointmentStatuses.inQueue:
      case AppointmentStatuses.inConsultation:
      case AppointmentStatuses.postConsultation:
        return AppColors.statusConfirmed;
      case AppointmentStatuses.completed:
        return AppColors.statusCompleted;
      case AppointmentStatuses.cancelled:
      case AppointmentStatuses.noShow:
        return AppColors.statusCancelled;
      default:
        return AppColors.textHint;
    }
  }

  String _statusText() {
    switch (AppointmentStatuses.normalize(status)) {
      case AppointmentStatuses.pendingBooking:
        return 'Cho dat lich';
      case AppointmentStatuses.booked:
        return 'Da dat';
      case AppointmentStatuses.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatuses.checkedIn:
        return 'Da check-in';
      case AppointmentStatuses.inQueue:
        return 'Dang cho kham';
      case AppointmentStatuses.inConsultation:
        return 'Dang kham';
      case AppointmentStatuses.postConsultation:
        return 'Sau kham';
      case AppointmentStatuses.rescheduled:
        return 'Da doi lich';
      case AppointmentStatuses.completed:
        return 'Hoàn thành';
      case AppointmentStatuses.cancelled:
        return 'Đã hủy';
      case AppointmentStatuses.noShow:
      case AppointmentStatuses.noShowPending:
        return 'Vang mat';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final normalizedStatus = AppointmentStatuses.normalize(status);
    final isCompleted = normalizedStatus == AppointmentStatuses.completed;
    final isCancelled = normalizedStatus == AppointmentStatuses.cancelled || normalizedStatus == AppointmentStatuses.noShow;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=200&auto=format&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _statusText(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(dateTime),
                                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(specialty, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 16, color: statusColor.withOpacity(0.8)),
                      const SizedBox(width: 8),
                      Text(
                        'Thời gian kham: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        DateFormat('HH:mm').format(dateTime),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (AppointmentStatuses.cancellable.contains(normalizedStatus) && onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Hủy lịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (isCompleted) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Đánh giá', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Đặt lại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    if (isCancelled)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Đặt lịch mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (!isCompleted && !isCancelled && !AppointmentStatuses.cancellable.contains(normalizedStatus))
                       Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Xem chi tiết', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

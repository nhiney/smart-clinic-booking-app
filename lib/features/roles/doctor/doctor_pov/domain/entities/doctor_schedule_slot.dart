enum ScheduleSlotType { urgent, first, revisit, online }
enum ScheduleSlotStatus { done, current, next, upcoming }

class DoctorScheduleSlot {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime dateTime;
  final int durationMinutes;
  final ScheduleSlotType type;
  final ScheduleSlotStatus status;
  final String note;
  final bool isVideo;
  final bool isUrgent;

  const DoctorScheduleSlot({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dateTime,
    required this.durationMinutes,
    required this.type,
    required this.status,
    required this.note,
    required this.isVideo,
    required this.isUrgent,
  });

  String get formattedTime {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get formattedDuration => '${durationMinutes}m';
}

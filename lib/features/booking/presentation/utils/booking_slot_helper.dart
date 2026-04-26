import 'package:intl/intl.dart';

import '../../../doctor/patient_pov//domain/entities/doctor_entity.dart';

/// Resolves candidate time labels for a calendar day from doctor schedule.
List<String> resolveTimeSlotsForDate(DoctorEntity? doctor, DateTime date) {
  if (doctor != null) {
    final en = DateFormat('EEEE', 'en_US').format(date);
    final vi = DateFormat('EEEE', 'vi_VN').format(date);
    for (final block in doctor.schedule) {
      final day = block.day.trim();
      if (day.isEmpty) continue;
      final dLower = day.toLowerCase();
      if (dLower == en.toLowerCase() ||
          day == vi ||
          vi.toLowerCase().contains(dLower) ||
          dLower.contains(vi.toLowerCase())) {
        if (block.slots.isNotEmpty) return List<String>.from(block.slots);
      }
    }
    if (doctor.availableTimeSlots.isNotEmpty) {
      return List<String>.from(doctor.availableTimeSlots);
    }
  }
  return const [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../domain/entities/medication_entity.dart';

class MedicationNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> scheduleMedicationReminder(MedicationEntity medication) async {
    await init();
    final times = _parseReminderTimes(medication.frequency, medication.time);
    for (var i = 0; i < times.length; i++) {
      final notifId = _notifIdFor(medication.id, i);
      final scheduledTime = _nextOccurrence(times[i]);
      await _plugin.zonedSchedule(
        notifId,
        'Medication Reminder',
        'Time to take ${medication.name} — ${medication.dosage}',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Reminders to take your medication',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancelMedicationReminders(String medicationId) async {
    await init();
    for (var i = 0; i < 3; i++) {
      await _plugin.cancel(_notifIdFor(medicationId, i));
    }
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  static int _notifIdFor(String medicationId, int index) {
    return '${medicationId}_$index'.hashCode.abs() % 100000 + index;
  }

  static List<String> _parseReminderTimes(String frequency, String primaryTime) {
    switch (frequency) {
      case '2 lần/ngày':
        return [primaryTime, _addHours(primaryTime, 8)];
      case '3 lần/ngày':
        return [primaryTime, _addHours(primaryTime, 6), _addHours(primaryTime, 12)];
      default:
        return [primaryTime];
    }
  }

  static String _addHours(String time, int hours) {
    final parts = time.split(':');
    final h = (int.parse(parts[0]) + hours) % 24;
    return '${h.toString().padLeft(2, '0')}:${parts[1]}';
  }

  static tz.TZDateTime _nextOccurrence(String time) {
    final parts = time.split(':');
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

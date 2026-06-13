import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Schedules local push notifications for appointment reminders.
/// No cost — uses flutter_local_notifications only.
class AppointmentReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _androidDetails = AndroidNotificationDetails(
    'appointment_reminders',
    'Appointment Reminders',
    channelDescription: 'Reminders for upcoming appointments',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static Future<void> _init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Schedule a 24-hour and a 1-hour reminder for an appointment.
  static Future<void> scheduleAppointmentReminders({
    required String appointmentId,
    required DateTime appointmentTime,
    required String doctorName,
    required String location,
  }) async {
    await _init();
    final now = DateTime.now();

    final oneDayBefore = appointmentTime.subtract(const Duration(hours: 24));
    final oneHourBefore = appointmentTime.subtract(const Duration(hours: 1));

    if (oneDayBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        _idFor(appointmentId, 0),
        'Appointment Tomorrow',
        'You have an appointment with $doctorName at $location tomorrow',
        tz.TZDateTime.from(oneDayBefore, tz.local),
        const NotificationDetails(android: _androidDetails, iOS: _iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (oneHourBefore.isAfter(now)) {
      await _plugin.zonedSchedule(
        _idFor(appointmentId, 1),
        'Appointment in 1 Hour',
        'Your appointment with $doctorName at $location starts in 1 hour',
        tz.TZDateTime.from(oneHourBefore, tz.local),
        const NotificationDetails(android: _androidDetails, iOS: _iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancel all reminders for a given appointment (e.g., on cancellation).
  static Future<void> cancelAppointmentReminders(String appointmentId) async {
    await _init();
    await _plugin.cancel(_idFor(appointmentId, 0));
    await _plugin.cancel(_idFor(appointmentId, 1));
  }

  /// Show an immediate notification for appointment confirmation.
  static Future<void> showAppointmentConfirmation({
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
    await _init();
    final timeStr = '${appointmentTime.day}/${appointmentTime.month} at ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}';
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'Appointment Confirmed',
      'Your appointment with $doctorName on $timeStr is confirmed.',
      const NotificationDetails(android: _androidDetails, iOS: _iosDetails),
    );
  }

  /// Show an immediate notification for appointment cancellation.
  static Future<void> showAppointmentCancellation({
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
    await _init();
    final timeStr = '${appointmentTime.day}/${appointmentTime.month}';
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'Appointment Cancelled',
      'Your appointment with $doctorName on $timeStr has been cancelled.',
      const NotificationDetails(android: _androidDetails, iOS: _iosDetails),
    );
  }

  static int _idFor(String appointmentId, int slot) {
    return '${appointmentId}_appt_$slot'.hashCode.abs() % 100000;
  }
}

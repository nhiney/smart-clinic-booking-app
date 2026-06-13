import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/services/fcm_service.dart';
import '../../data/services/appointment_reminder_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  List<NotificationEntity> notifications = [];
  List<NotificationLogEntity> notificationLogs = [];
  UserBehaviorEntity? userBehavior;
  bool isLoading = false;
  String? errorMessage;
  StreamSubscription<List<NotificationEntity>>? _watchSub;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Call once after login to register FCM token and start real-time watch.
  Future<void> initForUser(String userId) async {
    await FcmService.init();
    await FcmService.registerToken(userId);
    _startWatching(userId);
  }

  void _startWatching(String userId) {
    _watchSub?.cancel();
    _watchSub = repository.watchNotifications(userId).listen((list) {
      notifications = list;
      notifyListeners();
    });
  }

  static List<NotificationEntity> _demoNotifications(String userId) => [
    NotificationEntity(
      id: 'demo_n1',
      userId: userId,
      title: 'Lịch hẹn được xác nhận',
      body: 'Lịch khám với BS. Trần Minh Quân vào 09:30 ngày 14/06 đã được xác nhận. Vui lòng đến đúng giờ.',
      type: 'appointment_confirmed',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationEntity(
      id: 'demo_n2',
      userId: userId,
      title: 'Nhắc nhở uống thuốc',
      body: 'Đã đến giờ uống thuốc Amlodipine 5mg. Nhớ uống đúng giờ để thuốc phát huy hiệu quả tốt nhất.',
      type: 'medication',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationEntity(
      id: 'demo_n3',
      userId: userId,
      title: 'Kết quả xét nghiệm đã có',
      body: 'Kết quả xét nghiệm máu ngày 10/06 đã được cập nhật. Vào hồ sơ y tế để xem chi tiết.',
      type: 'result',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationEntity(
      id: 'demo_n4',
      userId: userId,
      title: 'Sắp đến lịch tái khám',
      body: 'Lịch tái khám tim mạch với GS.TS. Nguyễn Lân Việt vào 08:00 ngày 11/06 còn 1 ngày nữa.',
      type: 'appointment_reminder',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationEntity(
      id: 'demo_n5',
      userId: userId,
      title: 'Chào mừng đến với ICare',
      body: 'Cảm ơn bạn đã đăng ký ICare. Hãy đặt lịch khám ngay để chăm sóc sức khoẻ cùng đội ngũ bác sĩ uy tín.',
      type: 'system',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  Future<void> loadNotifications(String userId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      notifications = await repository.getNotifications(userId);
      notificationLogs = await repository.getNotificationLogs(userId);
      userBehavior = await repository.getUserBehavior(userId);

      if (notifications.isEmpty) {
        notifications = _demoNotifications(userId);
      }
    } catch (e) {
      errorMessage = 'Failed to load notifications';
      notifications = _demoNotifications(userId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── CREATE NOTIFICATIONS ────────────────────────────────────────────────

  Future<void> notifyAppointmentConfirmed({
    required String userId,
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentId,
    required String location,
  }) async {
    await repository.createNotification(
      userId: userId,
      title: 'Appointment Confirmed',
      body: 'Your appointment with Dr. $doctorName is confirmed.',
      type: 'appointment_confirmed',
      data: {'appointmentId': appointmentId},
    );
    // Schedule local 24h and 1h reminders
    await AppointmentReminderService.scheduleAppointmentReminders(
      appointmentId: appointmentId,
      appointmentTime: appointmentTime,
      doctorName: doctorName,
      location: location,
    );
    await AppointmentReminderService.showAppointmentConfirmation(
      doctorName: doctorName,
      appointmentTime: appointmentTime,
    );
  }

  Future<void> notifyAppointmentCancelled({
    required String userId,
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentId,
  }) async {
    await repository.createNotification(
      userId: userId,
      title: 'Appointment Cancelled',
      body: 'Your appointment with Dr. $doctorName has been cancelled.',
      type: 'appointment_cancelled',
      data: {'appointmentId': appointmentId},
    );
    await AppointmentReminderService.cancelAppointmentReminders(appointmentId);
    await AppointmentReminderService.showAppointmentCancellation(
      doctorName: doctorName,
      appointmentTime: appointmentTime,
    );
    // Track behavior
    await repository.recordBehavioralEvent(userId: userId, eventType: 'missed_appointment');
  }

  // ─── BEHAVIORAL ──────────────────────────────────────────────────────────

  Future<void> trackMissedAppointment(String userId) async {
    await repository.recordBehavioralEvent(userId: userId, eventType: 'missed_appointment');
    userBehavior = await repository.getUserBehavior(userId);
    notifyListeners();
  }

  // ─── READ / DELETE ────────────────────────────────────────────────────────

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to mark as read';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await repository.markAllAsRead(userId);
      notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to mark all as read';
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete notification';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _watchSub?.cancel();
    super.dispose();
  }
}

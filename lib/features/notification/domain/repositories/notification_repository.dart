import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String id);
}

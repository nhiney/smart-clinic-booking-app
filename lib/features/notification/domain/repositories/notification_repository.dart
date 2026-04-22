import '../entities/notification_entity.dart';
import '../entities/notification_data_entities.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Stream<List<NotificationEntity>> watchNotifications(String userId);
  Future<int> getUnreadCount(String userId);
  Future<NotificationEntity> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });
  Future<List<NotificationLogEntity>> getNotificationLogs(String userId);
  Future<UserBehaviorEntity?> getUserBehavior(String userId);
  Future<void> updateUserBehavior(UserBehaviorEntity behavior);
  Future<void> recordBehavioralEvent({required String userId, required String eventType});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String id);
}

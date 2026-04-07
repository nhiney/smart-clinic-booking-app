import '../entities/notification_entity.dart';
import '../entities/notification_data_entities.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<List<NotificationLogEntity>> getNotificationLogs(String userId);
  Future<UserBehaviorEntity?> getUserBehavior(String userId);
  Future<void> updateUserBehavior(UserBehaviorEntity behavior);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String id);
}

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_data_models.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) {
    return remoteDatasource.getNotifications(userId);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return remoteDatasource.watchNotifications(userId);
  }

  @override
  Future<int> getUnreadCount(String userId) {
    return remoteDatasource.getUnreadCount(userId);
  }

  @override
  Future<NotificationEntity> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) {
    return remoteDatasource.createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }

  @override
  Future<List<NotificationLogEntity>> getNotificationLogs(String userId) {
    return remoteDatasource.getNotificationLogs(userId);
  }

  @override
  Future<UserBehaviorEntity?> getUserBehavior(String userId) {
    return remoteDatasource.getUserBehavior(userId);
  }

  @override
  Future<void> updateUserBehavior(UserBehaviorEntity behavior) {
    return remoteDatasource.updateUserBehavior(
      UserBehaviorModel(
        userId: behavior.userId,
        missedAppointmentsCount: behavior.missedAppointmentsCount,
        urgencyMultiplier: behavior.urgencyMultiplier,
        lastUpdated: behavior.lastUpdated,
      ),
    );
  }

  @override
  Future<void> recordBehavioralEvent({required String userId, required String eventType}) {
    return remoteDatasource.recordBehavioralEvent(userId: userId, eventType: eventType);
  }

  @override
  Future<void> markAsRead(String id) {
    return remoteDatasource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead(String userId) {
    return remoteDatasource.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String id) {
    return remoteDatasource.deleteNotification(id);
  }
}

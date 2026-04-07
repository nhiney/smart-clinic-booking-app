import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_data_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_data_models.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    return await remoteDatasource.getNotifications(userId);
  }

  @override
  Future<List<NotificationLogEntity>> getNotificationLogs(String userId) async {
    return await remoteDatasource.getNotificationLogs(userId);
  }

  @override
  Future<UserBehaviorEntity?> getUserBehavior(String userId) async {
    return await remoteDatasource.getUserBehavior(userId);
  }

  @override
  Future<void> updateUserBehavior(UserBehaviorEntity behavior) async {
    final model = UserBehaviorModel(
      userId: behavior.userId,
      missedAppointmentsCount: behavior.missedAppointmentsCount,
      urgencyMultiplier: behavior.urgencyMultiplier,
      lastUpdated: behavior.lastUpdated,
    );
    await remoteDatasource.updateUserBehavior(model);
  }

  @override
  Future<void> markAsRead(String id) async {
    await remoteDatasource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await remoteDatasource.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await remoteDatasource.deleteNotification(id);
  }
}

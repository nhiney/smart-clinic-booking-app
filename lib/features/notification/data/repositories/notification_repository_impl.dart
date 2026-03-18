import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    return await remoteDatasource.getNotifications(userId);
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

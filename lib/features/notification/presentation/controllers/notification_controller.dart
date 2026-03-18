import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationController extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  List<NotificationEntity> notifications = [];
  bool isLoading = false;
  String? errorMessage;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      notifications = await repository.getNotifications(userId);
    } catch (e) {
      errorMessage = 'Không thể tải thông báo';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Không thể đánh dấu đã đọc';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await repository.markAllAsRead(userId);
      notifications = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Không thể đánh dấu tất cả đã đọc';
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Không thể xóa thông báo';
      notifyListeners();
    }
  }
}

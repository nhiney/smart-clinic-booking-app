import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../models/notification_data_models.dart';

class NotificationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Smart Notification - $0 Cost Simulation Logs
  Future<List<NotificationLogModel>> getNotificationLogs(String userId) async {
    final snapshot = await _firestore
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => NotificationLogModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> logFakeNotification(NotificationLogModel log) async {
    await _firestore.collection('notification_logs').add(log.toJson());
  }

  // User Behavior Tracking
  Future<UserBehaviorModel?> getUserBehavior(String userId) async {
    final doc = await _firestore.collection('user_behavior').doc(userId).get();
    if (!doc.exists) return null;
    return UserBehaviorModel.fromJson(doc.data()!, userId);
  }

  Future<void> updateUserBehavior(UserBehaviorModel behavior) async {
    await _firestore
        .collection('user_behavior')
        .doc(behavior.userId)
        .set(behavior.toJson(), SetOptions(merge: true));
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.data()['isRead'] == false) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }
}

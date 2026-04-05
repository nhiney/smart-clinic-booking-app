import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
        
    final notifications = snapshot.docs
        .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
        .toList();
        
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
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

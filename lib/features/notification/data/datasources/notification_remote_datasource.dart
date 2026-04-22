import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../models/notification_data_models.dart';

class NotificationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data(), doc.id)).toList();
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map((doc) => NotificationModel.fromJson(doc.data(), doc.id)).toList());
  }

  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final id = _uuid.v4();
    final doc = {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'data': data ?? {},
    };
    await _firestore.collection('notifications').doc(id).set(doc);
    return NotificationModel.fromJson({...doc, 'createdAt': Timestamp.now()}, id);
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }

  // ─── SMART / BEHAVIORAL ──────────────────────────────────────────────────

  Future<List<NotificationLogModel>> getNotificationLogs(String userId) async {
    final snapshot = await _firestore
        .collection('notification_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationLogModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<void> logFakeNotification(NotificationLogModel log) async {
    await _firestore.collection('notification_logs').add(log.toJson());
  }

  Future<UserBehaviorModel?> getUserBehavior(String userId) async {
    final doc = await _firestore.collection('user_behavior').doc(userId).get();
    if (!doc.exists) return null;
    return UserBehaviorModel.fromJson(doc.data()!, userId);
  }

  Future<void> updateUserBehavior(UserBehaviorModel behavior) async {
    await _firestore.collection('user_behavior').doc(behavior.userId).set(behavior.toJson(), SetOptions(merge: true));
  }

  /// Records a behavioral event and escalates urgency multiplier if needed.
  Future<void> recordBehavioralEvent({
    required String userId,
    required String eventType, // 'missed_appointment', 'late_checkin', 'low_adherence'
  }) async {
    final current = await getUserBehavior(userId);
    int missed = current?.missedAppointmentsCount ?? 0;
    if (eventType == 'missed_appointment') missed++;

    final multiplier = missed > 2 ? 2.0 : 1.0;
    final updated = UserBehaviorModel(
      userId: userId,
      missedAppointmentsCount: missed,
      urgencyMultiplier: multiplier,
      lastUpdated: DateTime.now(),
    );
    await updateUserBehavior(updated);

    // Also create an in-app smart reminder notification
    if (multiplier > 1.0) {
      await createNotification(
        userId: userId,
        title: 'Health Reminder',
        body: "You've missed recent appointments. Your health matters — please reschedule.",
        type: 'smart_reminder',
        data: {'eventType': eventType, 'missedCount': missed},
      );
    }
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles FCM token registration, foreground message display, and
/// appointment reminder scheduling via flutter_local_notifications.
class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();
  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Important Notifications',
    description: 'Appointment confirmations, reminders and alerts',
    importance: Importance.high,
  );

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Request permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Create Android channel
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Init local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Foreground: show local notification for FCM messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        payload: message.data['route'] as String?,
      );
    });

    _initialized = true;
  }

  /// Registers the current device's FCM token in Firestore under
  /// users/{uid}/fcm_tokens/{token}
  static Future<void> registerToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcm_tokens')
          .doc(token)
          .set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'registeredAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[FCM] Token registered: ${token.substring(0, 10)}...');
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  /// Removes the current device's FCM token on logout.
  static Future<void> unregisterToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fcm_tokens')
          .doc(token)
          .delete();
    } catch (_) {}
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    await _localNotif.show(
      id ?? DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: payload,
    );
  }

  /// Returns the current FCM token (for debugging / manual copy).
  static Future<String?> getToken() => _messaging.getToken();
}

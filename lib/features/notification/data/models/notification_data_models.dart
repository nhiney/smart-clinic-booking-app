import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_data_entities.dart';

class NotificationLogModel extends NotificationLogEntity {
  const NotificationLogModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.recipient,
    required super.content,
    super.status,
    required super.createdAt,
  });

  factory NotificationLogModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationLogModel(
      id: id,
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'sms',
      recipient: json['recipient'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'logged',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'recipient': recipient,
      'content': content,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class UserBehaviorModel extends UserBehaviorEntity {
  const UserBehaviorModel({
    required super.userId,
    required super.missedAppointmentsCount,
    super.urgencyMultiplier,
    required super.lastUpdated,
  });

  factory UserBehaviorModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserBehaviorModel(
      userId: userId,
      missedAppointmentsCount: json['missed_appointments_count'] ?? 0,
      urgencyMultiplier: (json['urgency_multiplier'] ?? 1.0).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? (json['last_updated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missed_appointments_count': missedAppointmentsCount,
      'urgency_multiplier': urgencyMultiplier,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }
}

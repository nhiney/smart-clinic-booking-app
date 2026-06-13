class NotificationLogEntity {
  final String id;
  final String userId;
  final String type; // sms | email
  final String recipient;
  final String content;
  final String status; // logged
  final DateTime createdAt;

  const NotificationLogEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.recipient,
    required this.content,
    this.status = 'logged',
    required this.createdAt,
  });
}

class UserBehaviorEntity {
  final String userId;
  final int missedAppointmentsCount;
  final double urgencyMultiplier;
  final DateTime lastUpdated;

  const UserBehaviorEntity({
    required this.userId,
    required this.missedAppointmentsCount,
    this.urgencyMultiplier = 1.0,
    required this.lastUpdated,
  });
}

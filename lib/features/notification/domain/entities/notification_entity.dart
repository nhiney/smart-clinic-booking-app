class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // appointment, medication, system
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'system',
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}

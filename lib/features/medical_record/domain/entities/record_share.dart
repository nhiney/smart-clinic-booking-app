import 'package:equatable/equatable.dart';

enum SharePermission { view, download }

class RecordShare extends Equatable {
  final String id;
  final String recordId;
  final String ownerId;
  final String sharedWithId;
  final SharePermission permission;
  final DateTime sharedAt;
  final DateTime? expiresAt;
  final bool isRevoked;

  const RecordShare({
    required this.id,
    required this.recordId,
    required this.ownerId,
    required this.sharedWithId,
    required this.permission,
    required this.sharedAt,
    this.expiresAt,
    this.isRevoked = false,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => !isRevoked && !isExpired;

  factory RecordShare.fromJson(Map<String, dynamic> json) {
    return RecordShare(
      id: json['id'] as String,
      recordId: json['recordId'] as String,
      ownerId: json['ownerId'] as String,
      sharedWithId: json['sharedWithId'] as String,
      permission: json['permission'] == 'download'
          ? SharePermission.download
          : SharePermission.view,
      sharedAt: json['sharedAt'] is String
          ? DateTime.parse(json['sharedAt'])
          : (json['sharedAt'] as dynamic).toDate(),
      expiresAt: json['expiresAt'] == null
          ? null
          : json['expiresAt'] is String
              ? DateTime.parse(json['expiresAt'])
              : (json['expiresAt'] as dynamic).toDate(),
      isRevoked: json['isRevoked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordId': recordId,
        'ownerId': ownerId,
        'sharedWithId': sharedWithId,
        'permission': permission.name,
        'sharedAt': sharedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'isRevoked': isRevoked,
      };

  @override
  List<Object?> get props => [id, recordId, ownerId, sharedWithId, isRevoked];
}

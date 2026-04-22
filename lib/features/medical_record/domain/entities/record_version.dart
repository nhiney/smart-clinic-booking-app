import 'package:equatable/equatable.dart';

class RecordVersion extends Equatable {
  final String id;
  final String recordId;
  final int versionNumber;
  final String changedBy;
  final String changeNote;
  final Map<String, dynamic> snapshot;
  final DateTime createdAt;

  const RecordVersion({
    required this.id,
    required this.recordId,
    required this.versionNumber,
    required this.changedBy,
    required this.changeNote,
    required this.snapshot,
    required this.createdAt,
  });

  factory RecordVersion.fromJson(Map<String, dynamic> json) {
    return RecordVersion(
      id: json['id'] as String,
      recordId: json['recordId'] as String,
      versionNumber: (json['versionNumber'] as num).toInt(),
      changedBy: json['changedBy'] as String? ?? '',
      changeNote: json['changeNote'] as String? ?? '',
      snapshot: Map<String, dynamic>.from(json['snapshot'] as Map? ?? {}),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordId': recordId,
        'versionNumber': versionNumber,
        'changedBy': changedBy,
        'changeNote': changeNote,
        'snapshot': snapshot,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, recordId, versionNumber, createdAt];
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Trạng thái của một khung giờ khám
enum SlotStatus {
  available,
  pending,
  confirmed,
}

class SlotEntity {
  final String id;
  final bool isAvailable;
  final SlotStatus status;
  final DateTime? lockedAt;
  final String? patientId;

  SlotEntity({
    required this.id,
    required this.isAvailable,
    required this.status,
    this.lockedAt,
    this.patientId,
  });

  factory SlotEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SlotEntity(
      id: doc.id,
      isAvailable: data['isAvailable'] ?? false,
      status: _parseStatus(data['status']),
      lockedAt: (data['lockedAt'] as Timestamp?)?.toDate(),
      patientId: data['patientId'],
    );
  }

  static SlotStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return SlotStatus.pending;
      case 'confirmed':
        return SlotStatus.confirmed;
      default:
        return SlotStatus.available;
    }
  }

  String get statusString {
    switch (status) {
      case SlotStatus.pending:
        return 'pending';
      case SlotStatus.confirmed:
        return 'confirmed';
      default:
        return 'available';
    }
  }
}

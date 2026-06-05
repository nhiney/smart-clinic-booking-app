import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_schedule_slot.dart';

class DoctorScheduleRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DoctorScheduleSlot>> getScheduleForDay(
    String doctorId,
    DateTime date,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('dateTime', isLessThan: Timestamp.fromDate(dayEnd))
        .orderBy('dateTime')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final rawStatus = (data['status'] ?? 'pendingBooking') as String;
      final priority = (data['priorityLevel'] ?? 'normal') as String;
      final notes = (data['notes'] ?? '') as String;
      final isVideo = notes.toLowerCase().contains('online') ||
          notes.toLowerCase().contains('video');

      return DoctorScheduleSlot(
        id: doc.id,
        patientId: data['patientId'] as String? ?? '',
        patientName: data['patientName'] as String? ?? 'Bệnh nhân',
        dateTime: (data['dateTime'] as Timestamp).toDate(),
        durationMinutes: data['durationMinutes'] as int? ?? 30,
        type: _mapType(priority, isVideo, notes),
        status: _mapStatus(rawStatus),
        note: notes,
        isVideo: isVideo,
        isUrgent: priority == 'urgent',
      );
    }).toList();
  }

  Future<void> updateSlotStatus(
    String appointmentId,
    ScheduleSlotStatus newStatus,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': _toFirestoreStatus(newStatus),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  ScheduleSlotType _mapType(String priority, bool isVideo, String notes) {
    if (priority == 'urgent') return ScheduleSlotType.urgent;
    if (isVideo) return ScheduleSlotType.online;
    if (notes.toLowerCase().contains('tái khám') ||
        notes.toLowerCase().contains('revisit')) {
      return ScheduleSlotType.revisit;
    }
    return ScheduleSlotType.first;
  }

  ScheduleSlotStatus _mapStatus(String raw) {
    switch (raw) {
      case 'completed':
        return ScheduleSlotStatus.done;
      case 'inProgress':
        return ScheduleSlotStatus.current;
      case 'checkedIn':
        return ScheduleSlotStatus.next;
      default:
        return ScheduleSlotStatus.upcoming;
    }
  }

  String _toFirestoreStatus(ScheduleSlotStatus status) {
    switch (status) {
      case ScheduleSlotStatus.done:
        return 'completed';
      case ScheduleSlotStatus.current:
        return 'inProgress';
      case ScheduleSlotStatus.next:
        return 'checkedIn';
      case ScheduleSlotStatus.upcoming:
        return 'confirmed';
    }
  }
}

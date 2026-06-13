import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_schedule_slot.dart';

class DoctorScheduleRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static List<DoctorScheduleSlot> _demoSlots(DateTime date) {
    final base = DateTime(date.year, date.month, date.day);
    return [
      DoctorScheduleSlot(
        id: 'demo_1',
        patientId: 'demo_pt1',
        patientName: 'Nguyễn Thị Mai',
        dateTime: base.add(const Duration(hours: 8, minutes: 0)),
        durationMinutes: 30,
        type: ScheduleSlotType.first,
        status: ScheduleSlotStatus.done,
        note: 'Đau ngực, khó thở',
        isVideo: false,
        isUrgent: false,
      ),
      DoctorScheduleSlot(
        id: 'demo_2',
        patientId: 'demo_pt2',
        patientName: 'Trần Văn Bình',
        dateTime: base.add(const Duration(hours: 8, minutes: 30)),
        durationMinutes: 30,
        type: ScheduleSlotType.revisit,
        status: ScheduleSlotStatus.done,
        note: 'Tái khám THA độ 2',
        isVideo: false,
        isUrgent: false,
      ),
      DoctorScheduleSlot(
        id: 'demo_3',
        patientId: 'demo_pt3',
        patientName: 'Lê Thị Hoa',
        dateTime: base.add(const Duration(hours: 9, minutes: 0)),
        durationMinutes: 30,
        type: ScheduleSlotType.online,
        status: ScheduleSlotStatus.current,
        note: 'Khám online - Tiểu đường type 2',
        isVideo: true,
        isUrgent: false,
      ),
      DoctorScheduleSlot(
        id: 'demo_4',
        patientId: 'demo_pt4',
        patientName: 'Phạm Quốc Toản',
        dateTime: base.add(const Duration(hours: 9, minutes: 30)),
        durationMinutes: 30,
        type: ScheduleSlotType.urgent,
        status: ScheduleSlotStatus.next,
        note: 'Đau ngực cấp - ưu tiên',
        isVideo: false,
        isUrgent: true,
      ),
      DoctorScheduleSlot(
        id: 'demo_5',
        patientId: 'demo_pt5',
        patientName: 'Võ Minh Tuấn',
        dateTime: base.add(const Duration(hours: 10, minutes: 0)),
        durationMinutes: 30,
        type: ScheduleSlotType.first,
        status: ScheduleSlotStatus.upcoming,
        note: 'Khám lần đầu - tim mạch',
        isVideo: false,
        isUrgent: false,
      ),
      DoctorScheduleSlot(
        id: 'demo_6',
        patientId: 'demo_pt6',
        patientName: 'Nguyễn Văn An',
        dateTime: base.add(const Duration(hours: 10, minutes: 30)),
        durationMinutes: 30,
        type: ScheduleSlotType.revisit,
        status: ScheduleSlotStatus.upcoming,
        note: 'Tái khám ĐTN không ổn định',
        isVideo: false,
        isUrgent: false,
      ),
    ];
  }

  Future<List<DoctorScheduleSlot>> getScheduleForDay(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('dateTime', isLessThan: Timestamp.fromDate(dayEnd))
          .get();

      final slots = snapshot.docs.map((doc) {
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
      }).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      if (slots.isEmpty) return _demoSlots(date);
      return slots;
    } catch (_) {
      return _demoSlots(date);
    }
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

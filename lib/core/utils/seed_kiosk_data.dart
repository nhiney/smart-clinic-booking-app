import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedKioskData() async {
  final firestore = FirebaseFirestore.instance;
  final doctorId = 'doctor_default_branch_a';
  
  print('Đang tạo dữ liệu mẫu cho Kiosk...');

  // Tạo một số khung giờ cho hôm nay
  final now = DateTime.now();
  final slots = [
    {'hour': 8, 'minute': 0},
    {'hour': 9, 'minute': 30},
    {'hour': 14, 'minute': 0},
    {'hour': 15, 'minute': 30},
  ];

  for (var time in slots) {
    final startTime = DateTime(now.year, now.month, now.day, time['hour']!, time['minute']!);
    final endTime = startTime.add(const Duration(minutes: 30));
    final slotId = 'slot_${time['hour']}_${time['minute']}';

    await firestore.collection('slots').doc(slotId).set({
      'doctorId': doctorId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': 'available',
      'price': 150000.0,
      'isAvailable': true,
    });
  }

  print('Đã tạo xong 4 khung giờ mẫu cho bác sĩ: $doctorId');
}

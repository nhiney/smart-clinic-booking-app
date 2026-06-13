// PHẦN 3 — Seed dữ liệu mẫu cho các màn đang trống + TEST VOICE đặt lịch kĩ.
//
// 1) Đăng nhập bệnh nhân → seed Firestore (appointments, medical_records,
//    medications + intakes, notifications, invoices, payments) cho đúng uid.
// 2) Chụp lại các màn trước đây trống, giờ đã có dữ liệu.
// 3) Test voice đặt lịch nhiều kịch bản: nói → phân tích ý định → popup chọn.
//
// Chạy:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/patient_seed_and_voice_test.dart -d <device>

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';
import 'package:smart_clinic_booking/features/support_services/ai/presentation/screens/voice_assistant_screen.dart';
import 'package:smart_clinic_booking/features/support_services/ai/presentation/riverpod/assistant_provider.dart';

const testPassword = 'Icare@123';
const testVirtualEmail = '84912345678@icare.patient';
// Rules cho phép email này ghi mọi collection (isAdmin theo token.email).
const adminEmail = 'admin@icare.com';
const adminPassword = 'Icare@123';

late IntegrationTestWidgetsFlutterBinding binding;
final List<String> stepLog = [];
final List<String> failures = [];

Future<void> settle(WidgetTester tester, {int ms = 1200}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<bool> waitFor(WidgetTester tester, Finder finder,
    {int timeoutMs = 12000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}

// Chụp qua `xcrun simctl io screenshot` ở tiến trình shell: in marker rồi GIỮ
// nguyên frame ~2s để shell kịp chụp framebuffer thật (binding.takeScreenshot
// trên iOS trả về frame trắng khi app bận nên không dùng nữa).
Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  // ignore: avoid_print
  print('[CAPTURE] $name');
  await settle(tester, ms: 2000);
  // ignore: avoid_print
  print('[SHOT] $name');
}

Future<void> step(String name, Future<void> Function() body) async {
  // ignore: avoid_print
  print('[STEP] ▶ $name');
  try {
    await body();
    stepLog.add('OK   $name');
  } catch (e, st) {
    stepLog.add('FAIL $name: $e');
    failures.add('$name: $e');
    // ignore: avoid_print
    print('[STEP-FAIL] $name: $e\n$st');
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bệnh nhân - PHẦN 3 - seed dữ liệu + voice đặt lịch',
      (tester) async {
    await app.main();
    await settle(tester, ms: 5000);
    // Firebase đã được app.main() khởi tạo — giờ mới lấy instance Firestore.
    final fs = FirebaseFirestore.instance;

    Future<void> signIn(String email, String pass) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: pass);
      } on FirebaseAuthException catch (_) {
        try {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: pass);
        } catch (e) {
          // ignore: avoid_print
          print('[AUTH] $email: $e');
        }
      }
    }

    // ── Lấy uid bệnh nhân thật ─────────────────────────────────────────────
    String uid = '';
    await step('Đăng nhập bệnh nhân (lấy uid)', () async {
      await signIn(testVirtualEmail, testPassword);
      uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      // ignore: avoid_print
      print('[SEED] patient uid = $uid');
      await settle(tester, ms: 1500);
    });

    // ── Đăng nhập admin để có quyền ghi mọi collection ─────────────────────
    bool adminOk = false;
    await step('Đăng nhập admin để seed (quyền ghi)', () async {
      await signIn(adminEmail, adminPassword);
      adminOk = FirebaseAuth.instance.currentUser?.email == adminEmail;
      // ignore: avoid_print
      print('[SEED] adminOk = $adminOk (current=${FirebaseAuth.instance.currentUser?.email})');
      await settle(tester, ms: 1500);
    });

    final now = DateTime.now();
    DateTime d(int days, [int h = 9, int m = 0]) =>
        DateTime(now.year, now.month, now.day + days, h, m);

    // ══════════════════════════ SEED FIRESTORE ════════════════════════════
    await step('SEED appointments (lịch hẹn)', () async {
      final col = fs.collection('appointments');
      final items = [
        {'specialty': 'Tim mạch', 'doctorName': 'BS. Trần Minh Quân',
         'dateTime': d(3, 9, 30), 'status': 'confirmed', 'paymentStatus': 'paid'},
        {'specialty': 'Da liễu', 'doctorName': 'BS. Lê Thị Hà',
         'dateTime': d(7, 14, 0), 'status': 'confirmed', 'paymentStatus': 'unpaid'},
        {'specialty': 'Nội khoa', 'doctorName': 'BS. Phạm Văn Đức',
         'dateTime': d(-10, 8, 0), 'status': 'completed', 'paymentStatus': 'paid'},
        {'specialty': 'Nhi khoa', 'doctorName': 'BS. Nguyễn Thu Trang',
         'dateTime': d(-25, 10, 30), 'status': 'completed', 'paymentStatus': 'paid'},
        {'specialty': 'Tai Mũi Họng', 'doctorName': 'BS. Vũ Hoàng Nam',
         'dateTime': d(-3, 15, 0), 'status': 'cancelled', 'paymentStatus': 'unpaid'},
      ];
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        await col.doc('seed_appt_$i').set({
          'patientId': uid,
          'patientName': 'Nguyễn Văn An',
          'doctorId': 'seed_doc_$i',
          'doctorName': it['doctorName'],
          'specialty': it['specialty'],
          'dateTime': Timestamp.fromDate(it['dateTime'] as DateTime),
          'status': it['status'],
          'paymentStatus': it['paymentStatus'],
          'notes': 'Lịch hẹn mẫu để kiểm thử',
          'queueNumber': '${i + 1}',
          'priorityLevel': 'normal',
          'createdAt': Timestamp.fromDate(now),
        });
      }
    });

    await step('SEED medical_records (hồ sơ y tế + đơn thuốc)', () async {
      final col = fs.collection('medical_records');
      final items = [
        {'diagnosis': 'Tăng huyết áp độ 1', 'doctor': 'BS. Trần Minh Quân',
         'rx': '- Amlodipine 5mg: 1 viên/ngày sau ăn sáng\n- Theo dõi huyết áp 2 lần/ngày',
         'when': d(-10), 'sym': ['Đau đầu', 'Chóng mặt']},
        {'diagnosis': 'Viêm da cơ địa', 'doctor': 'BS. Lê Thị Hà',
         'rx': '- Kem Hydrocortisone 1%: bôi 2 lần/ngày\n- Cetirizine 10mg: 1 viên buổi tối',
         'when': d(-25), 'sym': ['Ngứa', 'Nổi mẩn đỏ']},
        {'diagnosis': 'Viêm họng cấp', 'doctor': 'BS. Vũ Hoàng Nam',
         'rx': '- Amoxicillin 500mg: 1 viên x 3 lần/ngày trong 7 ngày\n- Súc họng nước muối',
         'when': d(-40), 'sym': ['Đau họng', 'Sốt nhẹ']},
      ];
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        final when = it['when'] as DateTime;
        await col.doc('seed_mr_$i').set({
          'patientId': uid,            // dùng cho màn Đơn thuốc
          'userId': uid,               // dùng cho màn Hồ sơ y tế
          'patientName': 'Nguyễn Văn An',
          'doctor': it['doctor'],
          'doctorName': it['doctor'],
          'diagnosis': it['diagnosis'],
          'prescription': it['rx'],
          'symptoms': it['sym'],
          'notes': 'Tái khám sau 2 tuần nếu không đỡ',
          'createdAt': Timestamp.fromDate(when),
          'examinedAt': Timestamp.fromDate(when),
        });
      }
    });

    await step('SEED medications + intakes (thuốc & lịch uống)', () async {
      final col = fs.collection('medications');
      final meds = [
        {'name': 'Amlodipine 5mg', 'dosage': '5mg', 'frequency': '1 lần/ngày',
         'time': '08:00', 'start': d(-10), 'end': d(20)},
        {'name': 'Cetirizine 10mg', 'dosage': '10mg', 'frequency': '1 lần/ngày',
         'time': '20:00', 'start': d(-25), 'end': d(5)},
        {'name': 'Vitamin C 1000mg', 'dosage': '1000mg', 'frequency': '1 lần/ngày',
         'time': '12:00', 'start': d(-5), 'end': null},
      ];
      for (var i = 0; i < meds.length; i++) {
        final m = meds[i];
        final docRef = col.doc('seed_med_$i');
        await docRef.set({
          'patientId': uid,
          'name': m['name'],
          'dosage': m['dosage'],
          'frequency': m['frequency'],
          'time': m['time'],
          'startDate': Timestamp.fromDate(m['start'] as DateTime),
          'endDate': m['end'] != null
              ? Timestamp.fromDate(m['end'] as DateTime) : null,
          'isActive': true,
          'notes': 'Uống sau ăn',
        });
        // 7 ngày gần nhất, mỗi ngày 1 lần uống (mix đã uống / chưa uống)
        for (var dch = 0; dch < 7; dch++) {
          final sched = DateTime(now.year, now.month, now.day - dch,
              int.parse((m['time'] as String).split(':')[0]), 0);
          final taken = dch > 0; // hôm nay chưa uống
          await docRef.collection('intakes').doc('intake_$dch').set({
            'id': 'intake_$dch',
            'medicationId': 'seed_med_$i',
            'patientId': uid,
            'scheduledAt': sched.toIso8601String(),
            'wasTaken': taken,
            'takenAt': taken ? sched.toIso8601String() : null,
            'note': null,
          });
        }
      }
    });

    await step('SEED notifications (thông báo)', () async {
      final col = fs.collection('notifications');
      final items = [
        {'title': 'Nhắc lịch khám', 'body': 'Bạn có lịch khám Tim mạch lúc 09:30 ngày mai với BS. Trần Minh Quân.', 'type': 'appointment', 'read': false},
        {'title': 'Nhắc uống thuốc', 'body': 'Đã đến giờ uống Amlodipine 5mg (08:00).', 'type': 'medication', 'read': false},
        {'title': 'Kết quả xét nghiệm', 'body': 'Kết quả xét nghiệm máu của bạn đã có. Nhấn để xem chi tiết.', 'type': 'result', 'read': false},
        {'title': 'Thanh toán thành công', 'body': 'Bạn đã thanh toán 350.000đ cho lịch khám Tim mạch.', 'type': 'payment', 'read': true},
        {'title': 'Ưu đãi gói khám', 'body': 'Giảm 20% gói khám sức khỏe tổng quát trong tháng này.', 'type': 'promotion', 'read': true},
        {'title': 'Đặt lịch thành công', 'body': 'Lịch khám Da liễu ngày kia đã được xác nhận.', 'type': 'appointment', 'read': true},
      ];
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        await col.doc('seed_noti_$i').set({
          'userId': uid,
          'title': it['title'],
          'body': it['body'],
          'type': it['type'],
          'isRead': it['read'],
          'createdAt': now.subtract(Duration(hours: i * 5)).millisecondsSinceEpoch,
          'data': {'eventType': it['type']},
        });
      }
    });

    await step('SEED invoices (hóa đơn)', () async {
      final col = fs.collection('invoices');
      final items = [
        {'svc': 'Khám Tim mạch', 'price': 350000, 'status': 'paid', 'when': d(-10)},
        {'svc': 'Khám Da liễu', 'price': 250000, 'status': 'pending', 'when': d(-1)},
        {'svc': 'Xét nghiệm máu tổng quát', 'price': 480000, 'status': 'paid', 'when': d(-25)},
      ];
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        final price = it['price'] as int;
        await col.doc('seed_inv_$i').set({
          'userId': uid,
          'services': [
            {'name': it['svc'], 'price': price, 'quantity': 1},
          ],
          'total': price.toDouble(),
          'paymentId': 'seed_pay_$i',
          'status': it['status'],
          'createdAt': Timestamp.fromDate(it['when'] as DateTime),
        });
      }
    });

    await step('SEED payments (giao dịch)', () async {
      final col = fs.collection('payments');
      final items = [
        {'amount': 350000, 'method': 'vnpay', 'status': 'success', 'desc': 'Khám Tim mạch', 'when': d(-10)},
        {'amount': 480000, 'method': 'momo', 'status': 'success', 'desc': 'Xét nghiệm máu', 'when': d(-25)},
        {'amount': 250000, 'method': 'stripe', 'status': 'pending', 'desc': 'Khám Da liễu', 'when': d(-1)},
      ];
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        await col.doc('seed_txn_$i').set({
          'userId': uid,
          'appointmentId': 'seed_appt_$i',
          'invoiceId': 'seed_inv_$i',
          'amount': (it['amount'] as int).toDouble(),
          'currency': 'VND',
          'method': it['method'],
          'status': it['status'],
          'description': it['desc'],
          'paymentRequestId': 'req_seed_$i',
          'retryCount': 0,
          'createdAt': Timestamp.fromDate(it['when'] as DateTime),
        });
      }
    });

    await step('SEED users/{uid} (hồ sơ — để AuthController nạp được)', () async {
      await fs.collection('users').doc(uid).set({
        'email': testVirtualEmail,
        'name': 'Nguyễn Văn An',
        'phone': '+84912345678',
        'role': 'patient',
        'status': 'active',
        'address': 'Quận 1, TP. Hồ Chí Minh',
        'profile': {
          'gender': 'Nam',
          'dateOfBirth': '1990-05-12',
          'bloodType': 'O+',
          'allergies': ['Penicillin'],
          'emergencyContact': '0987654321',
        },
        'createdAt': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    });

    await settle(tester, ms: 2000); // chờ Firestore commit

    // ── Đăng nhập lại bằng bệnh nhân để AuthController nạp profile (currentUser) ─
    await step('Đăng nhập lại bệnh nhân để xem', () async {
      await FirebaseAuth.instance.signOut();
      await settle(tester, ms: 1200);
      await signIn(testVirtualEmail, testPassword);
      AppRouter.mockAuthNotifier.value = true;
      AppRouter.clearRoleCache();
      // Chờ listener của AuthController nạp xong profile → currentUser != null
      // (các màn lịch hẹn/thông báo/thuốc/hóa đơn lọc theo currentUser.id).
      await settle(tester, ms: 5000);
      AppRouter.router.go('/home');
      await settle(tester, ms: 3000);
    });

    // ════════════════ CHỤP LẠI CÁC MÀN GIỜ ĐÃ CÓ DỮ LIỆU ═════════════════
    final dataScreens = <String, String>{
      '/appointments': '13_01_lich_hen_co_du_lieu',
      '/prescriptions': '13_02_don_thuoc_co_du_lieu',
      '/medical-records': '13_03_ho_so_y_te_co_du_lieu',
      '/medication': '13_04_quan_ly_thuoc_co_du_lieu',
      '/medication-schedule': '13_05_lich_uong_thuoc_co_du_lieu',
      '/notifications': '13_06_thong_bao_co_du_lieu',
      '/invoices': '13_07_hoa_don_co_du_lieu',
      '/transactions': '13_08_giao_dich_co_du_lieu',
    };
    for (final e in dataScreens.entries) {
      await step('Chụp ${e.key} (có dữ liệu)', () async {
        AppRouter.router.go('/home');
        await settle(tester, ms: 1000);
        AppRouter.router.push(e.key);
        await settle(tester, ms: 4500); // chờ tải dữ liệu Firestore
        await shot(tester, e.value);
        // Cuộn xem thêm nếu có danh sách
        final sc = find.byType(Scrollable);
        if (sc.evaluate().isNotEmpty) {
          await tester.drag(sc.first, const Offset(0, -350), warnIfMissed: false);
          await settle(tester, ms: 1200);
          await shot(tester, '${e.value}_cuon');
        }
      });
    }

    // ════════════════════════ TEST VOICE ĐẶT LỊCH KĨ ══════════════════════
    await step('14 Mở màn Voice AI', () async {
      AppRouter.router.go('/home');
      await settle(tester, ms: 1000);
      AppRouter.router.push('/ai/voice-assistant');
      await settle(tester, ms: 3000);
      await shot(tester, '14_01_voice_man_chinh');
    });

    // Lấy notifier voice từ ProviderScope của màn đang hiển thị
    AssistantNotifier? notifier;
    await step('14 Kết nối tới bộ xử lý giọng nói', () async {
      final ctx = tester.element(find.byType(VoiceAssistantScreen));
      final container = ProviderScope.containerOf(ctx);
      notifier = container.read(assistantProvider.notifier);
      expect(notifier, isNotNull);
    });

    // Đóng sheet nếu đang mở
    Future<void> closeSheet() async {
      final confirmBtn = find.text('Đặt lịch ngay');
      final retryBtn = find.text('Nói lại');
      if (confirmBtn.evaluate().isNotEmpty || retryBtn.evaluate().isNotEmpty) {
        // kéo sheet xuống để đóng
        try {
          await tester.drag(find.text('Xác nhận đặt lịch'),
              const Offset(0, 600), warnIfMissed: false);
        } catch (_) {}
        await settle(tester, ms: 800);
        notifier?.clearPendingBooking();
        await settle(tester, ms: 500);
      }
    }

    // KỊCH BẢN 1 — câu đầy đủ chuyên khoa + ngày + buổi → popup
    await step('14 KB1: "Đặt lịch khám nhi khoa ngày mai buổi sáng" → popup', () async {
      await notifier!.injectTranscript('Tôi muốn đặt lịch khám nhi khoa ngày mai buổi sáng');
      await settle(tester, ms: 1500);
      await shot(tester, '14_02_kb1_phan_tich_hoi_thoai');
      final ok = await waitFor(tester, find.text('Xác nhận đặt lịch'), timeoutMs: 6000);
      await shot(tester, '14_03_kb1_popup_nhi_khoa_sang');
      // ignore: avoid_print
      print('[VOICE] KB1 popup hiển thị = $ok');
      await closeSheet();
    });

    // KỊCH BẢN 2 — chuyên khoa khác + buổi chiều
    await step('14 KB2: "Đặt lịch khám da liễu chiều mai" → popup', () async {
      await notifier!.injectTranscript('Đặt lịch khám da liễu chiều mai');
      await settle(tester, ms: 1500);
      await waitFor(tester, find.text('Xác nhận đặt lịch'), timeoutMs: 6000);
      await shot(tester, '14_04_kb2_popup_da_lieu_chieu');
      await closeSheet();
    });

    // KỊCH BẢN 3 — thiếu chuyên khoa → AI hỏi lại (không popup)
    await step('14 KB3: "Tôi muốn đặt lịch khám" (thiếu khoa) → AI hỏi lại', () async {
      notifier!.clearChat();
      await settle(tester, ms: 500);
      await notifier!.injectTranscript('Tôi muốn đặt lịch khám');
      await settle(tester, ms: 2000);
      await shot(tester, '14_05_kb3_AI_hoi_lai_chuyen_khoa');
    });

    // KỊCH BẢN 4 — trả lời tiếp "nội khoa" (ngữ cảnh) → popup
    await step('14 KB4: trả lời "nội khoa" (ngữ cảnh) → popup', () async {
      await notifier!.injectTranscript('Nội khoa');
      await settle(tester, ms: 1500);
      await waitFor(tester, find.text('Xác nhận đặt lịch'), timeoutMs: 6000);
      await shot(tester, '14_06_kb4_context_popup_noi_khoa');
      // Nhập triệu chứng vào ô trong popup (người dùng chọn/bổ sung)
      final symptomField = find.byType(TextField);
      if (symptomField.evaluate().isNotEmpty) {
        await tester.enterText(symptomField.last, 'Đau bụng âm ỉ 2 ngày, ăn uống kém');
        await tester.pump(const Duration(milliseconds: 400));
        await shot(tester, '14_07_kb4_nhap_trieu_chung_trong_popup');
      }
      await closeSheet();
    });

    // KỊCH BẢN 5 — hỏi giờ làm việc
    await step('14 KB5: "Phòng khám làm việc mấy giờ" → trả lời', () async {
      notifier!.clearChat();
      await settle(tester, ms: 500);
      await notifier!.injectTranscript('Phòng khám làm việc mấy giờ');
      await settle(tester, ms: 2000);
      await shot(tester, '14_08_kb5_hoi_gio_lam_viec');
    });

    // KỊCH BẢN 6 — hủy lịch
    await step('14 KB6: "Hủy lịch khám" → trả lời', () async {
      await notifier!.injectTranscript('Tôi muốn hủy lịch khám');
      await settle(tester, ms: 2000);
      await shot(tester, '14_09_kb6_huy_lich');
    });

    // ── TỔNG KẾT ───────────────────────────────────────────────────────────
    // ignore: avoid_print
    print('══════════ KẾT QUẢ PHẦN 3 ══════════');
    for (final s in stepLog) {
      // ignore: avoid_print
      print(s);
    }
    if (failures.isNotEmpty) {
      // ignore: avoid_print
      print('CÓ ${failures.length} BƯỚC LỖI: $failures');
    }
  }, timeout: Timeout.none);
}

// Demo VIDEO — vai trò ADMIN (quản trị). Đầy đủ tính năng, kèm marker [STEP]
// để gắn phụ đề (quay bằng simctl recordVideo).
//
// flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/admin_demo_video_test.dart -d <iPhone-UDID>

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_clinic_booking/main.dart' as app;
import 'package:smart_clinic_booking/shared/router/app_router.dart';

const adminEmail = 'admin@icare.com';
const adminPassword = 'Icare@123';

late IntegrationTestWidgetsFlutterBinding binding;

// Seed dữ liệu cho 2 màn admin còn trống: Duyệt KYC bác sĩ + Kiểm duyệt đánh giá.
Future<void> seedAdminData() async {
  final fs = FirebaseFirestore.instance;
  final now = DateTime.now();

  // doctor_applications (status=pending) — màn /admin/kyc-approvals
  final apps = [
    {'fullName': 'BS. Phạm Văn Đức', 'specialty': 'Nhi khoa',
     'hospital': 'Bệnh viện Nhi Đồng 1', 'licenceNumber': 'CCHN-018245'},
    {'fullName': 'BS. Lê Thị Hồng', 'specialty': 'Da liễu',
     'hospital': 'Bệnh viện Da liễu TP.HCM', 'licenceNumber': 'CCHN-033190'},
    {'fullName': 'TS.BS. Hoàng Minh Tuấn', 'specialty': 'Tim mạch',
     'hospital': 'Bệnh viện Chợ Rẫy', 'licenceNumber': 'CCHN-007421'},
  ];
  for (var i = 0; i < apps.length; i++) {
    try {
      await fs.collection('doctor_applications').doc('demo_kyc_$i').set({
        ...apps[i],
        'status': 'pending',
        'tenantId': 'icare',
        'doctorUid': 'demo_doc_$i',
        'email': 'doctor$i@icare.com',
        'phone': '09010000$i$i',
        'submittedAt': Timestamp.fromDate(now.subtract(Duration(hours: i + 1))),
      });
    } catch (e) {
      // ignore: avoid_print
      print('[SEED-KYC-ERR] $e');
    }
  }

  // reviews — màn /admin/reviews
  final reviews = [
    {'userName': 'Nguyễn Thị Lan', 'doctorName': 'BS. Trần Minh Quân',
     'doctorId': 'doc_quan', 'rating': 5.0,
     'comment': 'Bác sĩ tận tâm, giải thích rõ ràng. Tôi rất hài lòng với buổi khám!'},
    {'userName': 'Trần Văn Hùng', 'doctorName': 'BS. Lê Thị Hoa',
     'doctorId': 'doc_hoa', 'rating': 4.0,
     'comment': 'Khám kỹ, thái độ thân thiện. Chờ hơi lâu một chút.'},
    {'userName': 'Phạm Minh Anh', 'doctorName': 'BS. Trần Minh Quân',
     'doctorId': 'doc_quan', 'rating': 5.0,
     'comment': 'Rất chuyên nghiệp, tư vấn nhiệt tình. Sẽ quay lại!'},
    {'userName': 'Vũ Thị Mai', 'doctorName': 'GS.TS. Nguyễn Lân Việt',
     'doctorId': 'doc_viet', 'rating': 3.0,
     'comment': 'Bác sĩ giỏi nhưng phòng khám hơi đông.'},
  ];
  for (var i = 0; i < reviews.length; i++) {
    try {
      await fs.collection('reviews').doc('demo_review_$i').set({
        ...reviews[i],
        'isHidden': false,
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: i))),
      });
    } catch (e) {
      // ignore: avoid_print
      print('[SEED-REVIEW-ERR] $e');
    }
  }
  // ignore: avoid_print
  print('[SEED] admin data done');
}

Future<void> beat(WidgetTester tester, int ms) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void step(String caption) {
  // ignore: avoid_print
  print('[STEP] $caption');
}

// Tab dưới: tap label rồi đặt caption khi nội dung đã hiện.
Future<void> tab(WidgetTester tester, String label, String caption,
    {int hold = 3600, bool scroll = false}) async {
  try {
    final f = find.text(label);
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first, warnIfMissed: false);
    }
    await beat(tester, 1400);
    step(caption);
    await beat(tester, hold);
    if (scroll) {
      final sc = find.byType(Scrollable);
      if (sc.evaluate().isNotEmpty) {
        await tester.drag(sc.first, const Offset(0, -420), warnIfMissed: false);
        await beat(tester, 2200);
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print('[TAB-ERR] $label: $e');
  }
}

// Route: về dashboard rồi push, đặt caption khi màn đã tải.
Future<void> route(WidgetTester tester, String r, String caption,
    {int hold = 3800, bool scroll = false}) async {
  try {
    AppRouter.router.go('/admin/dashboard');
    await beat(tester, 800);
    AppRouter.router.push(r);
    await beat(tester, 1500);
    step(caption);
    await beat(tester, hold);
    if (scroll) {
      final sc = find.byType(Scrollable);
      if (sc.evaluate().isNotEmpty) {
        await tester.drag(sc.first, const Offset(0, -420), warnIfMissed: false);
        await beat(tester, 2200);
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print('[ROUTE-ERR] $r: $e');
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin DEMO video - toàn bộ tính năng + chú thích',
      (tester) async {
    await app.main();
    await beat(tester, 5000);

    // ignore: avoid_print
    print('[DEMO-READY]');
    await beat(tester, 2500);

    // ───── ĐĂNG NHẬP NHÂN VIÊN / QUẢN TRỊ ─────
    step('Màn đăng nhập nhân viên / quản trị');
    AppRouter.router.go('/staff-login');
    await beat(tester, 3000);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: adminEmail, password: adminPassword);
    } catch (e) {
      // ignore: avoid_print
      print('[LOGIN-ADMIN] $e');
    }
    // Seed dữ liệu cho 2 màn còn trống (đăng nhập admin có quyền ghi).
    await seedAdminData();
    AppRouter.mockAuthNotifier.value = true;
    AppRouter.clearRoleCache();
    await beat(tester, 6000);

    AppRouter.router.go('/admin/dashboard');
    await beat(tester, 4000);

    // ───── DASHBOARD ─────
    step('Bảng điều khiển quản trị — tổng quan hệ thống');
    await beat(tester, 3600);
    final sc = find.byType(Scrollable);
    if (sc.evaluate().isNotEmpty) {
      await tester.drag(sc.first, const Offset(0, -450), warnIfMissed: false);
      await beat(tester, 700);
      step('Tổng quan — thống kê, biểu đồ doanh thu & hoạt động');
      await beat(tester, 3200);
      await tester.drag(sc.first, const Offset(0, 1500), warnIfMissed: false);
      await beat(tester, 700);
    }

    // ───── CÁC TAB QUẢN TRỊ ─────
    await tab(tester, 'Bệnh viện', 'Quản lý bệnh viện & phòng khám', scroll: true);
    await tab(tester, 'Bác sĩ', 'Quản lý bác sĩ trong hệ thống', scroll: true);
    await tab(tester, 'Nội dung', 'Quản lý nội dung — bài viết, tin tức sức khoẻ', scroll: true);
    await tab(tester, 'Cài đặt', 'Cài đặt hệ thống', scroll: true);

    // ───── CÁC MÀN QUẢN TRỊ KHÁC ─────
    await route(tester, '/admin/kyc-approvals', 'Duyệt hồ sơ KYC của bác sĩ đăng ký', scroll: true);
    await route(tester, '/admin/appointments', 'Quản lý toàn bộ lịch hẹn', scroll: true);
    await route(tester, '/admin/patients', 'Quản lý toàn bộ bệnh nhân', scroll: true);
    await route(tester, '/admin/broadcast', 'Gửi thông báo broadcast đến người dùng');
    await route(tester, '/admin/reviews', 'Kiểm duyệt đánh giá bác sĩ');

    await beat(tester, 1500);
    // ignore: avoid_print
    print('XONG - DEMO hoàn tất');
    await beat(tester, 1000);
  }, timeout: Timeout.none);
}

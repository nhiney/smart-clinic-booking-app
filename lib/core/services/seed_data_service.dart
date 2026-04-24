import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../features/admin/domain/entities/facility_entities.dart';
import '../../features/admin/data/repositories/firestore_facility_repository.dart';

class SeedDataService {
  final FirestoreFacilityRepository _repo = FirestoreFacilityRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedInitialData() async {
    // Check if hospitals already exist to avoid double seeding
    final hospitals = await _repo.getAllHospitals();
    if (hospitals.isNotEmpty) return;

    // 1. Create a Hospital
    final h1 = Hospital(
      id: 'hosp_cho_ray',
      name: 'Bệnh viện Chợ Rẫy',
      address: '201B Nguyễn Chí Thanh, Quận 5, TP.HCM',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Cho_Ray_Hospital_Logo.svg/1200px-Cho_Ray_Hospital_Logo.svg.png',
    );
    await _repo.addHospital(h1);

    // 2. Create Departments for Cho Ray
    final depts = [
      Department(id: 'choray_cardio', hospitalId: 'hosp_cho_ray', name: 'Khoa Tim mạch', description: 'Chuyên điều trị các bệnh lý tim mạch'),
      Department(id: 'choray_neuro', hospitalId: 'hosp_cho_ray', name: 'Khoa Ngoại thần kinh', description: 'Phẫu thuật và điều trị thần kinh'),
      Department(id: 'choray_ortho', hospitalId: 'hosp_cho_ray', name: 'Khoa Chấn thương chỉnh hình', description: 'Điều trị xương khớp và chấn thương'),
    ];
    for (var d in depts) {
      await _repo.addDepartment(d);
    }

    // 3. Create Rooms for Cardio
    final rooms = [
      Room(id: 'room_cardio_101', departmentId: 'choray_cardio', name: 'Phòng khám 101', type: 'Examination'),
      Room(id: 'room_cardio_102', departmentId: 'choray_cardio', name: 'Phòng Can thiệp tim mạch', type: 'Surgery'),
      Room(id: 'room_cardio_icu', departmentId: 'choray_cardio', name: 'ICU Tim mạch', type: 'ICU'),
    ];
    for (var r in rooms) {
      await _repo.addRoom(r);
    }

    // 4. Create Devices for ICU
    final devices = [
      Device(id: 'dev_ventilator_01', roomId: 'room_cardio_icu', name: 'Máy thở Puritan Bennet', status: 'active'),
      Device(id: 'dev_monitor_01', roomId: 'room_cardio_icu', name: 'Máy theo dõi bệnh nhân GE', status: 'active'),
    ];
    for (var dev in devices) {
      await _repo.addDevice(dev);
    }

    // 5. Seed Some Staff Accounts (Metadata in Firestore)
    await _seedStaffMetadata();
  }

  Future<void> _seedStaffMetadata() async {
    final staff = [
      {
        'uid': 'admin_default',
        'email': 'admin@icare.com',
        'role': 'admin',
        'name': 'Hệ thống Quản trị',
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'doctor_default',
        'email': 'annv.choray@icare.com',
        'name': 'BS. Nguyễn Văn An',
        'role': 'doctor',
        'hospital_id': 'hosp_cho_ray',
        'department_id': 'choray_cardio',
        'specialty': 'Tim mạch can thiệp',
        'experience_years': 10,
        'bio': 'Chuyên gia can thiệp tim mạch với 10 năm kinh nghiệm tại các bệnh viện lớn.',
        'address': 'TP. Hồ Chí Minh',
        'status': 'active',
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (var s in staff) {
      await _firestore.collection('users').doc(s['uid'] as String).set(s);
    }
  }

  Future<void> seedSamplePatients() async {
    final patients = [
      {'phone': '0912345678', 'name': 'Bệnh nhân Test', 'address': 'Hệ thống'},
      {'phone': '0901234567', 'name': 'Nguyễn Văn A', 'address': 'Hà Nội'},
      {'phone': '0901234568', 'name': 'Trần Thị B', 'address': 'Đà Nẵng'},
      {'phone': '0901234569', 'name': 'Lê Văn C', 'address': 'TP.HCM'},
      {'phone': '0908888999', 'name': 'Phạm Minh D', 'address': 'Cần Thơ'},
      {'phone': '0907777666', 'name': 'Hoàng Gia E', 'address': 'Hải Phòng'},
    ];

    int successCount = 0;
    for (var p in patients) {
      final success = await _createPatientAccount(p);
      if (success) successCount++;
    }
    
    if (successCount == 0) {
      throw Exception('Không tạo được tài khoản nào. Vui lòng kiểm tra Firebase Console (Bật Email/Password provider).');
    }
  }

  Future<void> seedSurveys() async {
    final existing = await _firestore.collection('surveys').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final surveys = [
      {
        'title': 'Đánh giá chất lượng dịch vụ khám bệnh',
        'description': 'Giúp chúng tôi cải thiện trải nghiệm khám bệnh của bạn tại iCare.',
        'category': 'Dịch vụ',
        'estimatedMinutes': 3,
        'responseCount': 0,
        'options': [
          {'id': 'opt_very_satisfied', 'text': 'Rất hài lòng'},
          {'id': 'opt_satisfied', 'text': 'Hài lòng'},
          {'id': 'opt_neutral', 'text': 'Bình thường'},
          {'id': 'opt_unsatisfied', 'text': 'Không hài lòng'},
        ],
        'results': {
          'opt_very_satisfied': 0,
          'opt_satisfied': 0,
          'opt_neutral': 0,
          'opt_unsatisfied': 0,
        },
        'questions': [
          {
            'id': 'q1',
            'text': 'Bạn đánh giá thế nào về thời gian chờ đợi tại phòng khám?',
            'type': 'single_choice',
            'options': ['Rất nhanh (dưới 15 phút)', 'Chấp nhận được (15-30 phút)', 'Hơi lâu (30-60 phút)', 'Quá lâu (trên 60 phút)'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q2',
            'text': 'Nhân viên lễ tân có thái độ phục vụ như thế nào?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q3',
            'text': 'Bạn có hài lòng với quy trình đặt lịch khám trực tuyến không?',
            'type': 'single_choice',
            'options': ['Rất hài lòng', 'Hài lòng', 'Bình thường', 'Không hài lòng'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q4',
            'text': 'Bạn có điều gì muốn góp ý để chúng tôi cải thiện không?',
            'type': 'text',
            'options': <String>[],
            'required': false,
            'maxRating': 5,
          },
        ],
      },
      {
        'title': 'Khảo sát về bác sĩ và chuyên môn',
        'description': 'Chia sẻ trải nghiệm của bạn với đội ngũ bác sĩ của chúng tôi.',
        'category': 'Bác sĩ',
        'estimatedMinutes': 4,
        'responseCount': 0,
        'options': [
          {'id': 'opt_excellent', 'text': 'Xuất sắc'},
          {'id': 'opt_good', 'text': 'Tốt'},
          {'id': 'opt_average', 'text': 'Trung bình'},
          {'id': 'opt_poor', 'text': 'Kém'},
        ],
        'results': {
          'opt_excellent': 0,
          'opt_good': 0,
          'opt_average': 0,
          'opt_poor': 0,
        },
        'questions': [
          {
            'id': 'q1',
            'text': 'Bác sĩ có lắng nghe và giải thích rõ ràng tình trạng bệnh của bạn không?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q2',
            'text': 'Bác sĩ có đề xuất phương án điều trị phù hợp không?',
            'type': 'single_choice',
            'options': ['Rất phù hợp', 'Phù hợp', 'Cần cải thiện', 'Chưa phù hợp'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q3',
            'text': 'Bạn đánh giá chuyên môn của bác sĩ điều trị?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q4',
            'text': 'Chuyên khoa bạn đã khám là gì?',
            'type': 'single_choice',
            'options': ['Tim mạch', 'Nội tổng hợp', 'Ngoại khoa', 'Nhi khoa', 'Da liễu', 'Khác'],
            'required': false,
            'maxRating': 5,
          },
        ],
      },
      {
        'title': 'Trải nghiệm người dùng ứng dụng iCare',
        'description': 'Phản hồi về ứng dụng giúp chúng tôi xây dựng sản phẩm tốt hơn.',
        'category': 'Trải nghiệm',
        'estimatedMinutes': 3,
        'responseCount': 0,
        'options': [
          {'id': 'opt_love', 'text': 'Rất thích'},
          {'id': 'opt_like', 'text': 'Thích'},
          {'id': 'opt_ok', 'text': 'Tạm được'},
          {'id': 'opt_dislike', 'text': 'Không thích'},
        ],
        'results': {
          'opt_love': 0,
          'opt_like': 0,
          'opt_ok': 0,
          'opt_dislike': 0,
        },
        'questions': [
          {
            'id': 'q1',
            'text': 'Bạn đánh giá mức độ dễ sử dụng của ứng dụng iCare?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q2',
            'text': 'Bạn thường sử dụng tính năng nào nhất?',
            'type': 'multiple_choice',
            'options': ['Đặt lịch khám', 'Xem hồ sơ sức khỏe', 'Đọc tin tức y tế', 'Liên hệ hỗ trợ', 'Khảo sát & Đánh giá'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q3',
            'text': 'Bạn có muốn giới thiệu ứng dụng này cho người thân không?',
            'type': 'single_choice',
            'options': ['Chắc chắn có', 'Có thể', 'Không chắc', 'Không'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q4',
            'text': 'Tính năng bạn muốn được bổ sung thêm là gì?',
            'type': 'text',
            'options': <String>[],
            'required': false,
            'maxRating': 5,
          },
        ],
      },
      {
        'title': 'Khảo sát sức khỏe và dinh dưỡng',
        'description': 'Giúp chúng tôi hiểu thói quen sức khỏe của bạn để tư vấn tốt hơn.',
        'category': 'Dinh dưỡng',
        'estimatedMinutes': 5,
        'responseCount': 0,
        'options': [
          {'id': 'opt_daily', 'text': 'Hàng ngày'},
          {'id': 'opt_weekly', 'text': 'Hàng tuần'},
          {'id': 'opt_rarely', 'text': 'Ít khi'},
          {'id': 'opt_never', 'text': 'Không bao giờ'},
        ],
        'results': {
          'opt_daily': 0,
          'opt_weekly': 0,
          'opt_rarely': 0,
          'opt_never': 0,
        },
        'questions': [
          {
            'id': 'q1',
            'text': 'Bạn có ăn đủ 3 bữa mỗi ngày không?',
            'type': 'single_choice',
            'options': ['Luôn luôn', 'Thường xuyên', 'Thỉnh thoảng', 'Hiếm khi'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q2',
            'text': 'Bạn tập thể dục bao nhiêu lần mỗi tuần?',
            'type': 'single_choice',
            'options': ['Không tập', '1-2 lần', '3-4 lần', '5 lần trở lên'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q3',
            'text': 'Bạn thường ăn những loại thực phẩm nào?',
            'type': 'multiple_choice',
            'options': ['Rau xanh & trái cây', 'Thịt đỏ', 'Hải sản', 'Đồ ăn nhanh', 'Ngũ cốc nguyên hạt'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q4',
            'text': 'Bạn uống bao nhiêu lít nước mỗi ngày?',
            'type': 'single_choice',
            'options': ['Dưới 1 lít', '1-2 lít', '2-3 lít', 'Trên 3 lít'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q5',
            'text': 'Bạn có muốn nhận tư vấn dinh dưỡng từ chuyên gia không?',
            'type': 'rating',
            'options': <String>[],
            'required': false,
            'maxRating': 5,
          },
        ],
      },
      {
        'title': 'Đánh giá cơ sở vật chất bệnh viện',
        'description': 'Đánh giá môi trường và trang thiết bị tại cơ sở y tế.',
        'category': 'Cơ sở vật chất',
        'estimatedMinutes': 3,
        'responseCount': 0,
        'options': [
          {'id': 'opt_5star', 'text': '5 sao'},
          {'id': 'opt_4star', 'text': '4 sao'},
          {'id': 'opt_3star', 'text': '3 sao'},
          {'id': 'opt_2star', 'text': '2 sao'},
        ],
        'results': {
          'opt_5star': 0,
          'opt_4star': 0,
          'opt_3star': 0,
          'opt_2star': 0,
        },
        'questions': [
          {
            'id': 'q1',
            'text': 'Phòng chờ có sạch sẽ và thoải mái không?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q2',
            'text': 'Biển chỉ dẫn trong bệnh viện có rõ ràng không?',
            'type': 'single_choice',
            'options': ['Rất rõ ràng', 'Rõ ràng', 'Khó hiểu', 'Rất khó tìm đường'],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q3',
            'text': 'Trang thiết bị y tế có hiện đại không?',
            'type': 'rating',
            'options': <String>[],
            'required': true,
            'maxRating': 5,
          },
          {
            'id': 'q4',
            'text': 'Bạn có nhận xét gì về cơ sở vật chất?',
            'type': 'text',
            'options': <String>[],
            'required': false,
            'maxRating': 5,
          },
        ],
      },
    ];

    final batch = _firestore.batch();
    for (final survey in surveys) {
      final ref = _firestore.collection('surveys').doc();
      batch.set(ref, survey);
    }
    await batch.commit();
    debugPrint('[SEED] Đã tạo ${surveys.length} khảo sát mẫu');
  }

  Future<bool> _createPatientAccount(Map<String, String> p) async {
    final phone = p['phone']!;
    final name = p['name']!;
    final address = p['address']!;
    
    // LOGIN SCREEN normalizes 090... -> 8490... (exactly 11 digits for VN)
    String normalized = phone;
    if (normalized.startsWith('0')) {
      normalized = '84${normalized.substring(1)}';
    } else if (!normalized.startsWith('84')) {
      normalized = '84$normalized';
    }
    
    final email = '$normalized@icare.patient';
    const password = 'Icare@123'; // Uniform password

    try {
      final secondaryAppName = 'SecondaryAuthApp_${DateTime.now().millisecondsSinceEpoch}';
      final secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: Firebase.app().options,
      );
      
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      try {
        final result = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final uid = result.user!.uid;
        
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'phone': phone,
          'name': name,
          'address': address,
          'role': 'patient',
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
        });
        
        debugPrint('[SEED] OK: $name ($email)');
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Re-sync profile
          final authUser = (await secondaryAuth.signInWithEmailAndPassword(email: email, password: password)).user;
          if (authUser != null) {
             await _firestore.collection('users').doc(authUser.uid).set({
              'email': email,
              'phone': phone,
              'name': name,
              'role': 'patient',
              'status': 'active',
              'updated_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
          return true;
        } else {
          debugPrint('[SEED] Auth Error ($email): ${e.code} - ${e.message}');
          return false;
        }
      } finally {
        await secondaryApp.delete();
      }
    } catch (e) {
      debugPrint('[SEED] Error ($email): $e');
      return false;
    }
  }
}

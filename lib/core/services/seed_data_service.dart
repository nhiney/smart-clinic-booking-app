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

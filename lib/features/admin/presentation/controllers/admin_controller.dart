// lib/features/admin/presentation/controllers/admin_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';
import '../../../doctor/patient_pov/domain/entities/doctor_entity.dart';
import '../../../doctor/patient_pov/domain/repositories/doctor_repository.dart';
import '../../../../core/services/seed_data_service.dart';
import '../../../../core/utils/seed_hospital_data.dart';
import '../../domain/entities/admin_dashboard_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log_entity.dart';

import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/models/user_model.dart';

class AdminController extends ChangeNotifier {
  final FacilityRepository facilityRepository;
  final DoctorRepository doctorRepository;
  final AuthRemoteDatasource authRemoteDatasource;
  List<SystemServiceEntity> systemServices = [];

  AdminController({
    required this.facilityRepository,
    required this.doctorRepository,
    required this.authRemoteDatasource,
  });

  bool isLoading = false;
  String? errorMessage;

  AdminDashboardEntity? dashboardData;
  String selectedPeriod = '7 ngày';
  
  List<Hospital> hospitals = [];
  List<Department> selectedDepartments = [];
  List<Room> selectedRooms = [];
  List<Patient> patients = [];
  List<Device> selectedDevices = [];
  List<DoctorEntity> unassignedDoctors = [];
  List<DoctorEntity> allDoctors = [];

  Hospital? selectedHospital;
  Department? selectedDepartment;

  void changePeriod(String period) {
    selectedPeriod = period;
    fetchDashboardOverview();
  }

  Future<void> fetchDashboardOverview() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      final rawData = await facilityRepository.getAdminDashboardData(selectedPeriod);
      
      String realAdminName = "Hệ thống Quản trị";
      try {
        final UserModel? currentUser = await authRemoteDatasource.getCurrentUser() as UserModel?;
        if (currentUser != null && currentUser.name.isNotEmpty) {
          realAdminName = currentUser.name;
        }
      } catch (_) {
        realAdminName = rawData.adminName;
      }

      final List<double> firebaseRevenueList = rawData.revenue.chartData;
      
      double maxVal = firebaseRevenueList.isNotEmpty 
          ? firebaseRevenueList.reduce((a, b) => a > b ? a : b) 
          : 1.0;

      final List<HospitalRevenueItem> dynamicTopHospitals = List.generate(firebaseRevenueList.length, (index) {
        String currentHospitalName = 'Cơ sở thành viên ${index + 1}';
        if (hospitals.isNotEmpty && index < hospitals.length) {
          currentHospitalName = hospitals[index].name;
        }
        
        return HospitalRevenueItem(
          name: currentHospitalName,
          revenueValue: firebaseRevenueList[index],
          rank: index + 1,
          percentageOfMax: firebaseRevenueList[index] / maxVal,
        );
      });

      dynamicTopHospitals.sort((a, b) => b.revenueValue.compareTo(a.revenueValue));
      
      final List<HospitalRevenueItem> rankedHospitals = List.generate(dynamicTopHospitals.length, (index) {
        final item = dynamicTopHospitals[index];
        return HospitalRevenueItem(
          name: item.name,
          revenueValue: item.revenueValue,
          rank: index + 1,
          percentageOfMax: item.percentageOfMax,
        );
      });

      dashboardData = rawData.copyWith(
        adminName: realAdminName,
        topHospitals: rankedHospitals,
      );

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ArticleEntity> articles = [];

  Future<void> fetchHospitals() async {
    try {
      isLoading = true;
      notifyListeners();
      hospitals = await facilityRepository.getAllHospitals();
      await fetchAllDoctors();
      await fetchDashboardOverview();
      await fetchArticles();

      if (hospitals.isNotEmpty) {
        await selectHospital(hospitals.first);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  CollectionReference<Map<String, dynamic>> get _articlesRef =>
      FirebaseFirestore.instance.collection('articles');

  /// Loads articles from Firestore. Seeds a few defaults on first run so the
  /// content tab is not empty.
  Future<void> fetchArticles() async {
    final snap = await _articlesRef.get();
    if (snap.docs.isEmpty) {
      const defaults = [
        ArticleEntity(id: 'art_01', title: '5 dấu hiệu cảnh báo bệnh tim mạch', authorName: 'Trần Minh Quân', category: 'Tim mạch', status: 'Đã xuất bản', views: 12400, publishDate: '23/05'),
        ArticleEntity(id: 'art_02', title: 'Chế độ ăn cho người tiểu đường', authorName: 'Nguyễn T. Lan', category: 'Dinh dưỡng', status: 'Đã xuất bản', views: 8200, publishDate: '21/05'),
        ArticleEntity(id: 'art_03', title: 'Hướng dẫn chăm sóc trẻ sốt cao', authorName: 'Phạm V. Đức', category: 'Nhi khoa', status: 'Đang soạn', views: 0, publishDate: 'Nháp'),
      ];
      for (final a in defaults) {
        await _articlesRef.doc(a.id).set(a.toMap());
      }
      articles = List.from(defaults);
    } else {
      articles = snap.docs.map((d) => ArticleEntity.fromMap(d.data(), d.id)).toList();
    }
    notifyListeners();
  }

  Future<void> addNewArticle(ArticleEntity newArticle) async {
    final id = newArticle.id.isNotEmpty ? newArticle.id : _articlesRef.doc().id;
    await _articlesRef.doc(id).set(newArticle.toMap());
    articles.insert(0, ArticleEntity.fromMap(newArticle.toMap(), id));
    notifyListeners();
  }

  Future<void> fetchAllDoctors() async {
    try {
      allDoctors = await doctorRepository.getDoctors();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  /// Approve or reject a doctor account by writing its `status`
  /// ('approved' | 'rejected') to the `doctors` collection.
  Future<void> setDoctorStatus(String doctorId, String status) async {
    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({'status': status, 'statusUpdatedAt': FieldValue.serverTimestamp()});
    await fetchAllDoctors();
    notifyListeners();
  }

  Future<void> selectHospital(Hospital hospital) async {
    selectedHospital = hospital;
    isLoading = true;
    notifyListeners();
    try {
      selectedDepartments = await facilityRepository.getDepartmentsByHospital(hospital.id);
      
      if (selectedDepartments.isNotEmpty) {
        await selectDepartment(selectedDepartments.first);
      } else {
        selectedDepartment = null;
        patients = [];
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDepartment(Department department) async {
    selectedDepartment = department;
    isLoading = true;
    notifyListeners();
    try {
      patients = await facilityRepository.getPatientsByDepartment(department.id);
      
      selectedRooms = await facilityRepository.getRoomsByDepartment(department.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepartments(String hospitalId) async {
    try {
      isLoading = true;
      notifyListeners();
      selectedDepartments = await facilityRepository.getDepartmentsByHospital(hospitalId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRooms(String departmentId) async {
    try {
      isLoading = true;
      notifyListeners();
      selectedRooms = await facilityRepository.getRoomsByDepartment(departmentId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Department CRUD ─────────────────────────────────────────────────────────
  Future<void> addDepartment({required String hospitalId, required String name, String description = ''}) async {
    await facilityRepository.addDepartment(Department(
      id: 'dept_${DateTime.now().millisecondsSinceEpoch}',
      hospitalId: hospitalId,
      name: name,
      description: description,
    ));
    if (selectedHospital != null) await selectHospital(selectedHospital!);
  }

  Future<void> deleteDepartment(String id) async {
    await facilityRepository.deleteDepartment(id);
    if (selectedHospital != null) await selectHospital(selectedHospital!);
  }

  // ── Room CRUD ───────────────────────────────────────────────────────────────
  Future<void> addRoom({required String departmentId, required String name, String type = 'Khám bệnh'}) async {
    await facilityRepository.addRoom(Room(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      departmentId: departmentId,
      name: name,
      type: type,
    ));
    await fetchRooms(departmentId);
  }

  Future<void> deleteRoom(String id, String departmentId) async {
    await facilityRepository.deleteRoom(id);
    await fetchRooms(departmentId);
  }

  Future<void> fetchDevices(String roomId) async {
    try {
      isLoading = true;
      notifyListeners();
      selectedDevices = await facilityRepository.getDevicesByRoom(roomId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHospital(Hospital hospital) async {
    await facilityRepository.addHospital(hospital);
    await fetchHospitals();
  }

  Future<void> fetchUnassignedDoctors() async {
    try {
      isLoading = true;
      notifyListeners();
      unassignedDoctors = await doctorRepository.getUnassignedDoctors();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignDoctor({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await doctorRepository.assignDoctorToDepartment(
        doctorId: doctorId,
        hospitalId: hospitalId,
        departmentId: departmentId,
      );
      await fetchUnassignedDoctors();
      await fetchDashboardOverview();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> createDoctor({
    required String fullName,
    required String hospitalId,
    required String hospitalName,
    required String departmentId,
    String? phone,
    String specialty = '',
    int experienceYears = 0,
    String bio = '',
    String address = '',
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      
      final doctor = await authRemoteDatasource.createDoctorAccount(
        fullName: fullName,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        departmentId: departmentId,
        phone: phone,
        specialty: specialty,
        experienceYears: experienceYears,
        bio: bio,
        address: address,
      );
      return doctor;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seedData() async {
    try {
      isLoading = true;
      notifyListeners();
      await SeedDataService().seedInitialData();
      await seedHospitalData();
      await fetchHospitals();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> seedDepartmentsAndDoctors() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      final result = await forceSeedDepartmentsAndDoctors();
      await fetchHospitals();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return 'Lỗi: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seedPatients() async {
    try {
      isLoading = true;
      notifyListeners();
      await SeedDataService().seedSamplePatients();
      await fetchDashboardOverview();
      if (selectedDepartment != null) {
        await selectDepartment(selectedDepartment!);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateArticle(ArticleEntity updatedArticle) async {
    await _articlesRef.doc(updatedArticle.id).set(updatedArticle.toMap());
    final index = articles.indexWhere((element) => element.id == updatedArticle.id);
    if (index != -1) {
      articles[index] = updatedArticle;
    } else {
      articles.insert(0, updatedArticle);
    }
    notifyListeners();
  }

  Future<void> deleteArticle(String articleId) async {
    await _articlesRef.doc(articleId).delete();
    articles.removeWhere((element) => element.id == articleId);
    notifyListeners();
  }
  Future<void> fetchSystemStatus() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final snapshot = await FirebaseFirestore.instance.collection('system_status').get();
      
      systemServices = snapshot.docs.map((doc) => 
        SystemServiceEntity.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
      
    } catch (e) {
      errorMessage = "Lỗi tải trạng thái hệ thống: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

List<AuditLogEntity> auditLogs = [];

  Future<void> fetchAuditLogs() async {
    final snapshot = await FirebaseFirestore.instance.collection('audit_logs')
        .orderBy('timestamp', descending: true).get();
    auditLogs = snapshot.docs.map((doc) => AuditLogEntity.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }

  // ── Appointment Management ───────────────────────────────────────────────────
  List<Map<String, dynamic>> allAppointments = [];
  bool appointmentsLoading = false;

  Future<void> fetchAllAppointments({String? statusFilter}) async {
    try {
      appointmentsLoading = true;
      notifyListeners();
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('dateTime', descending: true)
          .limit(100);
      if (statusFilter != null && statusFilter != 'all') {
        query = query.where('status', isEqualTo: statusFilter);
      }
      final snap = await query.get();
      allAppointments = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      appointmentsLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('appointments').doc(id).update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
    final idx = allAppointments.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      allAppointments[idx] = {...allAppointments[idx], 'status': status};
      notifyListeners();
    }
  }

  // ── Patient Management (global) ──────────────────────────────────────────────
  List<Map<String, dynamic>> allPatientUsers = [];

  Future<void> fetchAllPatientUsers({String? searchQuery}) async {
    try {
      isLoading = true;
      notifyListeners();
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .limit(200)
          .get();
      allPatientUsers = snap.docs.map((d) => {...d.data(), 'id': d.id}).where((u) {
        if (searchQuery == null || searchQuery.isEmpty) return true;
        final name = (u['name'] as String? ?? '').toLowerCase();
        final phone = (u['phone'] as String? ?? '').toLowerCase();
        return name.contains(searchQuery.toLowerCase()) || phone.contains(searchQuery.toLowerCase());
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Review Moderation ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> allReviews = [];

  Future<void> fetchAllReviews() async {
    try {
      isLoading = true;
      notifyListeners();
      final snap = await FirebaseFirestore.instance
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      allReviews = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setReviewHidden(String id, {required bool hidden}) async {
    await FirebaseFirestore.instance.collection('reviews').doc(id).update({'isHidden': hidden});
    final idx = allReviews.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      allReviews[idx] = {...allReviews[idx], 'isHidden': hidden};
      notifyListeners();
    }
  }

  Future<void> deleteReview(String id) async {
    await FirebaseFirestore.instance.collection('reviews').doc(id).delete();
    allReviews.removeWhere((r) => r['id'] == id);
    notifyListeners();
  }

  // ── Notification Broadcast ───────────────────────────────────────────────────
  List<Map<String, dynamic>> broadcastHistory = [];
  bool broadcastLoading = false;

  Future<int> broadcastNotification({
    required String title,
    required String body,
    required String targetRole,
  }) async {
    try {
      broadcastLoading = true;
      notifyListeners();
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('users');
      if (targetRole != 'all') {
        q = q.where('role', isEqualTo: targetRole);
      }
      final usersSnap = await q.limit(500).get();
      final batches = <WriteBatch>[];
      var batch = FirebaseFirestore.instance.batch();
      int count = 0;
      for (final userDoc in usersSnap.docs) {
        final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': userDoc.id,
          'title': title,
          'body': body,
          'type': 'broadcast',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        count++;
        if (count % 400 == 0) {
          batches.add(batch);
          batch = FirebaseFirestore.instance.batch();
        }
      }
      batches.add(batch);
      for (final b in batches) {
        await b.commit();
      }
      await FirebaseFirestore.instance.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'targetRole': targetRole,
        'recipientCount': usersSnap.docs.length,
        'sentAt': FieldValue.serverTimestamp(),
      });
      await fetchBroadcastHistory();
      return usersSnap.docs.length;
    } catch (e) {
      errorMessage = e.toString();
      return 0;
    } finally {
      broadcastLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBroadcastHistory() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('broadcast_notifications')
          .orderBy('sentAt', descending: true)
          .limit(20)
          .get();
      broadcastHistory = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchBroadcastHistory error: $e');
    }
  }
}
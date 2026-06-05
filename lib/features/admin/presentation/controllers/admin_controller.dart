// lib/features/admin/presentation/controllers/admin_controller.dart
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

      articles = List.from([
        const ArticleEntity(
          id: 'art_01',
          title: '5 dấu hiệu cảnh báo bệnh tim mạch',
          authorName: 'Trần Minh Quân',
          category: 'Tim mạch',
          status: 'Đã xuất bản',
          views: 12400,
          publishDate: '23/05',
        ),
        const ArticleEntity(
          id: 'art_02',
          title: 'Chế độ ăn cho người tiểu đường',
          authorName: 'Nguyễn T. Lan',
          category: 'Dinh dưỡng',
          status: 'Đã xuất bản',
          views: 8200,
          publishDate: '21/05',
        ),
        const ArticleEntity(
          id: 'art_03',
          title: 'Hướng dẫn chăm sóc trẻ sốt cao',
          authorName: 'Phạm V. Đức',
          category: 'Nhi khoa',
          status: 'Đang soạn',
          views: 0,
          publishDate: 'Nháp',
        ),
      ]);

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

  void addNewArticle(ArticleEntity newArticle) {
    articles.insert(0, newArticle);
    notifyListeners();
  }

  Future<void> fetchAllDoctors() async {
    try {
      allDoctors = await doctorRepository.getDoctors();
    } catch (e) {
      errorMessage = e.toString();
    }
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

  void updateArticle(ArticleEntity updatedArticle) {
    final index = articles.indexWhere((element) => element.id == updatedArticle.id);
    if (index != -1) {
      articles[index] = updatedArticle;
      notifyListeners();
    }
  }

  void deleteArticle(String articleId) {
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
        .orderBy('timestamp', descending: true).get(); // Sắp xếp theo thời gian
    auditLogs = snapshot.docs.map((doc) => AuditLogEntity.fromMap(doc.data(), doc.id)).toList();
    notifyListeners();
  }
}
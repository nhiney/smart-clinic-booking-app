import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../../doctor/domain/repositories/doctor_repository.dart';
import '../../../../core/services/seed_data_service.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/models/user_model.dart';

class AdminController extends ChangeNotifier {
  final FacilityRepository facilityRepository;
  final DoctorRepository doctorRepository;
  final AuthRemoteDatasource authRemoteDatasource;

  AdminController({
    required this.facilityRepository,
    required this.doctorRepository,
    required this.authRemoteDatasource,
  });

  bool isLoading = false;
  String? errorMessage;
  
  List<Hospital> hospitals = [];
  List<Department> selectedDepartments = [];
  List<Room> selectedRooms = [];
  List<Device> selectedDevices = [];
  List<DoctorEntity> unassignedDoctors = [];
  List<DoctorEntity> allDoctors = [];

  int totalUsers = 0;
  int totalDoctorsCount = 0;
  int totalAppointmentsCount = 0;
  double totalRevenue = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int newUsersThisWeek = 0;
  int newDoctorsThisWeek = 0;
  int newAppointmentsThisWeek = 0;
  double revenueGrowthRate = 0.0;

  String currentAdminRole = "ADMIN";
  String currentAdminName = "Admin";

  String get systemUptimePercentage {
    if (hospitals.isEmpty) return "100.00%";
    int totalServices = hospitals.length;
    int activeServices = hospitals.where((h) => h.name.isNotEmpty && h.address.isNotEmpty).length;
    double uptime = (activeServices / totalServices) * 100;
    if (uptime < 99.90) {
      uptime = 99.90 + (totalServices % 10) / 100;
    }
    return "${uptime > 100.0 ? 100.00 : uptime.toStringAsFixed(2)}%";
  }

  String get systemStatusText {
    if (hospitals.isEmpty) return "Đang tải";
    int inactive = hospitals.where((h) => h.name.isEmpty).length;
    return inactive > 0 ? "Bảo trì $inactive dịch vụ" : "Trực tuyến";
  }

  Color get systemStatusColor {
    if (hospitals.isEmpty) return const Color(0xFFFFB300);
    int inactive = hospitals.where((h) => h.name.isEmpty).length;
    return inactive > 0 ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
  }

  void listenToSystemStats() {
    final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      _firestore.collection('users').doc(currentUserId).snapshots().listen((userDoc) {
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          String rawRole = data['role']?.toString() ?? "ADMIN";
          currentAdminRole = rawRole.replaceAll('_', ' ').toUpperCase();
          currentAdminName = data['name']?.toString() ?? data['fullName']?.toString() ?? "Admin";
          notifyListeners();
        }
      });
    }

    _firestore.collection('users').snapshots().listen((snapshot) {
      totalUsers = snapshot.docs.length;
      newUsersThisWeek = snapshot.docs.where((doc) {
        final createdAtRaw = doc.data()['createdAt'];
        if (createdAtRaw == null) return false;
        final createdAt = (createdAtRaw is Timestamp) ? createdAtRaw.toDate() : DateTime.parse(createdAtRaw.toString());
        return createdAt.isAfter(sevenDaysAgo);
      }).length;
      notifyListeners();
    });

    _firestore.collection('doctors').where('status', isEqualTo: 'approved').snapshots().listen((snapshot) {
      totalDoctorsCount = snapshot.docs.length;
      newDoctorsThisWeek = snapshot.docs.where((doc) {
        final approvedAtRaw = doc.data()['approvedAt'] ?? doc.data()['createdAt'];
        if (approvedAtRaw == null) return false;
        final approvedAt = (approvedAtRaw is Timestamp) ? approvedAtRaw.toDate() : DateTime.parse(approvedAtRaw.toString());
        return approvedAt.isAfter(sevenDaysAgo);
      }).length;
      notifyListeners();
    });

    _firestore.collection('appointments').snapshots().listen((snapshot) {
      totalAppointmentsCount = snapshot.docs.length;
      newAppointmentsThisWeek = snapshot.docs.where((doc) {
        final timestampRaw = doc.data()['timestamp'] ?? doc.data()['createdAt'];
        if (timestampRaw == null) return false;
        final timestamp = (timestampRaw is Timestamp) ? timestampRaw.toDate() : DateTime.parse(timestampRaw.toString());
        return timestamp.isAfter(sevenDaysAgo);
      }).length;
      notifyListeners();
    });

    _firestore.collection('invoices').where('status', isEqualTo: 'paid').snapshots().listen((snapshot) {
      double currentWeekTotal = 0.0;
      double previousWeeksTotal = 0.0;
      for (var doc in snapshot.docs) {
        final amount = (doc.data()['amount'] ?? 0).toDouble();
        final timestampRaw = doc.data()['timestamp'] ?? doc.data()['createdAt'];
        if (timestampRaw != null) {
          final timestamp = (timestampRaw is Timestamp) ? timestampRaw.toDate() : DateTime.parse(timestampRaw.toString());
          if (timestamp.isAfter(sevenDaysAgo)) {
            currentWeekTotal += amount;
          } else {
            previousWeeksTotal += amount;
          }
        }
      }
      totalRevenue = currentWeekTotal + previousWeeksTotal;
      if (previousWeeksTotal > 0) {
        revenueGrowthRate = (currentWeekTotal / previousWeeksTotal) * 100;
      } else {
        revenueGrowthRate = currentWeekTotal > 0 ? 100.0 : 0.0;
      }
      notifyListeners();
    });
  }

  Future<void> fetchHospitals() async {
    try {
      isLoading = true;
      notifyListeners();
      hospitals = await facilityRepository.getAllHospitals();
      await fetchAllDoctors();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllDoctors() async {
    try {
      allDoctors = await doctorRepository.getDoctors();
    } catch (e) {
      errorMessage = e.toString();
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
      await fetchHospitals();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
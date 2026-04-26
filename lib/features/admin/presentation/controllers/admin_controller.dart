import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';
import '../../../doctor/patient_pov//domain/entities/doctor_entity.dart';
import '../../../doctor/patient_pov//domain/repositories/doctor_repository.dart';
import '../../../../core/services/seed_data_service.dart';
import '../../../../core/utils/seed_hospital_data.dart';

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
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../../doctor/domain/repositories/doctor_repository.dart';

class AdminAssignmentController extends ChangeNotifier {
  final FacilityRepository facilityRepository;
  final DoctorRepository doctorRepository;

  AdminAssignmentController({
    required this.facilityRepository,
    required this.doctorRepository,
  });

  bool isLoading = false;
  String? errorMessage;

  List<DoctorEntity> doctors = [];
  List<Hospital> hospitals = [];
  List<Department> departments = [];
  List<Room> rooms = [];

  DoctorEntity? selectedDoctor;
  Hospital? selectedHospital;
  Department? selectedDepartment;
  Room? selectedRoom;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    try {
      isLoading = true;
      notifyListeners();
      
      hospitals = await facilityRepository.getAllHospitals();
      doctors = await doctorRepository.getDoctors();
      
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectDoctor(DoctorEntity? doctor) {
    selectedDoctor = doctor;
    notifyListeners();
  }

  Future<void> selectHospital(Hospital? hospital) async {
    selectedHospital = hospital;
    selectedDepartment = null;
    selectedRoom = null;
    departments = [];
    rooms = [];
    
    if (hospital != null) {
      try {
        isLoading = true;
        notifyListeners();
        departments = await facilityRepository.getDepartmentsByHospital(hospital.id);
      } catch (e) {
        errorMessage = e.toString();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<void> selectDepartment(Department? department) async {
    selectedDepartment = department;
    selectedRoom = null;
    rooms = [];
    
    if (department != null) {
      try {
        isLoading = true;
        notifyListeners();
        rooms = await facilityRepository.getRoomsByDepartment(department.id);
      } catch (e) {
        errorMessage = e.toString();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  void selectRoom(Room? room) {
    selectedRoom = room;
    notifyListeners();
  }

  Future<bool> submitAssignment() async {
    if (selectedDoctor == null || 
        selectedHospital == null || 
        selectedDepartment == null || 
        selectedRoom == null) {
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('doctors').doc(selectedDoctor!.id).update({
        'hospitalId': selectedHospital!.id,
        'hospitalName': selectedHospital!.name,
        'departmentId': selectedDepartment!.id,
        'roomId': selectedRoom!.id,
        'roomName': selectedRoom!.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
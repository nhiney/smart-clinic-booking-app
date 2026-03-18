import 'package:flutter/material.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';

class DoctorController extends ChangeNotifier {
  final DoctorRepository repository;

  DoctorController({required this.repository});

  List<DoctorEntity> doctors = [];
  List<DoctorEntity> filteredDoctors = [];
  DoctorEntity? selectedDoctor;
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedSpecialty = '';

  final List<String> specialties = [
    'Tất cả',
    'Tim mạch',
    'Da liễu',
    'Thần kinh',
    'Nhi khoa',
    'Mắt',
    'Tai mũi họng',
    'Nội khoa',
    'Ngoại khoa',
  ];

  Future<void> loadDoctors() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      doctors = await repository.getDoctors();
      filteredDoctors = List.from(doctors);
    } catch (e) {
      errorMessage = 'Không thể tải danh sách bác sĩ';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDoctorDetail(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedDoctor = await repository.getDoctorById(id);
    } catch (e) {
      errorMessage = 'Không thể tải thông tin bác sĩ';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchDoctorsLocal(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void filterBySpecialty(String specialty) {
    selectedSpecialty = specialty == 'Tất cả' ? '' : specialty;
    _applyFilters();
  }

  void _applyFilters() {
    filteredDoctors = doctors.where((doctor) {
      final matchesSearch = searchQuery.isEmpty ||
          doctor.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSpecialty = selectedSpecialty.isEmpty ||
          doctor.specialty == selectedSpecialty;
      return matchesSearch && matchesSpecialty;
    }).toList();
    notifyListeners();
  }
}

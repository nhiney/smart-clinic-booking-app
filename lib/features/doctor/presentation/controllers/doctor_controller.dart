import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../../appointment/domain/repositories/appointment_repository.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';
import '../../../../core/services/file_storage_service.dart';

class DoctorController extends ChangeNotifier {
  final DoctorRepository doctorRepository;
  final AppointmentRepository appointmentRepository;
  final FileStorageService storageService;

  DoctorController({
    required this.doctorRepository,
    required this.appointmentRepository,
    required this.storageService,
  });

  bool isLoading = false;
  String? errorMessage;
  DoctorEntity? currentDoctor;
  List<AppointmentEntity> todayAppointments = [];
  Map<String, int> stats = {
    'today_total': 0,
    'waiting': 0,
    'confirmed': 0,
  };

  Future<void> fetchDoctorProfile(String doctorId) async {
    try {
      isLoading = true;
      notifyListeners();
      currentDoctor = await doctorRepository.getDoctorProfile(doctorId);
      await fetchDashboardData(doctorId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData(String doctorId) async {
    try {
      final appointments = await appointmentRepository.getAppointmentsByDoctor(doctorId);
      
      // Filter for today
      final now = DateTime.now();
      todayAppointments = appointments.where((a) {
        return a.dateTime.year == now.year &&
               a.dateTime.month == now.month &&
               a.dateTime.day == now.day;
      }).toList();

      // Calculate stats
      int waiting = todayAppointments.where((a) => a.status == AppointmentStatuses.checkedIn || a.status == AppointmentStatuses.inQueue).length;
      int confirmed = todayAppointments.where((a) => a.status == AppointmentStatuses.confirmed || a.status == AppointmentStatuses.booked).length;
      
      stats = {
        'today_total': todayAppointments.length,
        'waiting': waiting,
        'confirmed': confirmed,
      };
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  Future<void> updateProfile(DoctorEntity updatedDoctor) async {
    try {
      isLoading = true;
      notifyListeners();
      await doctorRepository.updateDoctorProfile(updatedDoctor);
      currentDoctor = updatedDoctor;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadResume(String doctorId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        isLoading = true;
        notifyListeners();

        final file = File(result.files.single.path!);
        final downloadUrl = await storageService.uploadDoctorResume(
          doctorId: doctorId,
          file: file,
        );

        // Update local state and Firestore
        final updatedDoctor = DoctorEntity(
          id: currentDoctor!.id,
          name: currentDoctor!.name,
          specialty: currentDoctor!.specialty,
          experience: currentDoctor!.experience,
          about: currentDoctor!.about,
          resumePdfUrl: downloadUrl,
          departmentId: currentDoctor!.departmentId,
        );

        await doctorRepository.assignDoctorToDepartment(
          doctorId: doctorId,
          hospitalId: currentDoctor!.hospital,
          departmentId: currentDoctor!.departmentId,
          // resumePdfUrl should be added to the assignment/update logic in repository
        );
        
        // Better: implement a specific updateResumeUrl in repo
        currentDoctor = updatedDoctor;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

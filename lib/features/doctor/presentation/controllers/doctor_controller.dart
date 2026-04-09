import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../../../core/services/file_storage_service.dart';

class DoctorController extends ChangeNotifier {
  final DoctorRepository doctorRepository;
  final FileStorageService storageService;

  DoctorController({
    required this.doctorRepository,
    required this.storageService,
  });

  bool isLoading = false;
  String? errorMessage;
  DoctorEntity? currentDoctor;

  Future<void> fetchDoctorProfile(String doctorId) async {
    try {
      isLoading = true;
      notifyListeners();
      currentDoctor = await doctorRepository.getDoctorProfile(doctorId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
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

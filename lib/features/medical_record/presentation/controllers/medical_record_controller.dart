import 'package:flutter/material.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/repositories/medical_record_repository.dart';

class MedicalRecordController extends ChangeNotifier {
  final MedicalRecordRepository repository;

  MedicalRecordController({required this.repository});

  List<MedicalRecordEntity> records = [];
  MedicalRecordEntity? selectedRecord;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadRecords(String patientId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      records = await repository.getRecordsByPatient(patientId);
    } catch (e) {
      errorMessage = 'Không thể tải hồ sơ bệnh án';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecordDetail(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedRecord = await repository.getRecordById(id);
    } catch (e) {
      errorMessage = 'Không thể tải chi tiết bệnh án';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

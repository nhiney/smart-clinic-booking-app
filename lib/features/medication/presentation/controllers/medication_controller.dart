import 'package:flutter/material.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../data/models/medication_model.dart';

class MedicationController extends ChangeNotifier {
  final MedicationRepository repository;

  MedicationController({required this.repository});

  List<MedicationEntity> medications = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMedications(String patientId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      medications = await repository.getMedicationsByPatient(patientId);
    } catch (e) {
      errorMessage = 'Không thể tải danh sách thuốc';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMedication(MedicationModel medication) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final created = await repository.addMedication(medication);
      medications.add(created);
      return true;
    } catch (e) {
      errorMessage = 'Không thể thêm thuốc';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      await repository.deleteMedication(id);
      medications.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Không thể xóa thuốc';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleMedication(String id, bool isActive) async {
    try {
      await repository.toggleMedication(id, isActive);
      final index = medications.indexWhere((m) => m.id == id);
      if (index != -1) {
        final old = medications[index];
        medications[index] = MedicationEntity(
          id: old.id,
          patientId: old.patientId,
          name: old.name,
          dosage: old.dosage,
          frequency: old.frequency,
          time: old.time,
          startDate: old.startDate,
          endDate: old.endDate,
          isActive: isActive,
          notes: old.notes,
        );
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Không thể cập nhật trạng thái';
      notifyListeners();
    }
  }
}

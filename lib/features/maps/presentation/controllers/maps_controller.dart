import 'package:flutter/material.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/maps_repository.dart';

class MapsController extends ChangeNotifier {
  final MapsRepository repository;

  MapsController({required this.repository});

  List<ClinicEntity> clinics = [];
  ClinicEntity? selectedClinic;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadClinics() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      clinics = await repository.getClinics();
    } catch (e) {
      errorMessage = 'Không thể tải danh sách phòng khám';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectClinic(ClinicEntity clinic) {
    selectedClinic = clinic;
    notifyListeners();
  }

  void clearSelection() {
    selectedClinic = null;
    notifyListeners();
  }
}

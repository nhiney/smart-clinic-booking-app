import 'package:flutter/material.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/usecases/get_patient_profile.dart';
import '../../domain/usecases/update_patient_profile.dart';

enum PatientProfileStatus { initial, loading, loaded, updating, success, error }

class PatientProfileController extends ChangeNotifier {
  final GetPatientProfile getPatientProfileUseCase;
  final UpdatePatientProfile updatePatientProfileUseCase;

  PatientProfileController({
    required this.getPatientProfileUseCase,
    required this.updatePatientProfileUseCase,
  });

  PatientProfile? _profile;
  PatientProfile? get profile => _profile;

  PatientProfileStatus _status = PatientProfileStatus.initial;
  PatientProfileStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(String userId, String userPhone) async {
    _status = PatientProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await getPatientProfileUseCase(userId);
      _profile = result ?? PatientProfile.empty(userPhone);
      _status = PatientProfileStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PatientProfileStatus.error;
    }
    notifyListeners();
  }

  Future<bool> updateProfile(PatientProfile profile) async {
    _status = PatientProfileStatus.updating;
    _errorMessage = null;
    notifyListeners();

    try {
      await updatePatientProfileUseCase(profile);
      _profile = profile;
      _status = PatientProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PatientProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetStatus() {
    if (_status == PatientProfileStatus.success || _status == PatientProfileStatus.error) {
      _status = PatientProfileStatus.loaded;
      notifyListeners();
    }
  }
}

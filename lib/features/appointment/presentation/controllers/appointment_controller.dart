import 'package:flutter/material.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentController extends ChangeNotifier {
  final AppointmentRepository repository;

  AppointmentController({required this.repository});

  List<AppointmentEntity> appointments = [];
  bool isLoading = false;
  String? errorMessage;

  List<AppointmentEntity> get upcomingAppointments => appointments
      .where((a) => a.status == 'pending' || a.status == 'confirmed')
      .toList();

  List<AppointmentEntity> get completedAppointments => appointments
      .where((a) => a.status == 'completed')
      .toList();

  List<AppointmentEntity> get cancelledAppointments => appointments
      .where((a) => a.status == 'cancelled')
      .toList();

  Future<void> loadAppointments(String patientId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      appointments = await repository.getAppointmentsByPatient(patientId);
    } catch (e) {
      errorMessage = 'Không thể tải lịch hẹn';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment(AppointmentEntity appointment) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final created = await repository.createAppointment(appointment);
      appointments.insert(0, created);
      
      return true;
    } catch (e) {
      errorMessage = 'Không thể tạo lịch hẹn';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String id) async {
    try {
      await repository.cancelAppointment(id);
      final index = appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(status: 'cancelled');
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Không thể hủy lịch hẹn';
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentController extends ChangeNotifier {
  final AppointmentRepository repository;

  AppointmentController({required this.repository});

  List<AppointmentEntity> appointments = [];
  bool isLoading = false;
  String? errorMessage;

  List<AppointmentEntity> get upcomingAppointments =>
      appointments.where((a) => a.isUpcoming).toList();

  List<AppointmentEntity> get completedAppointments => appointments
      .where((a) => a.normalizedStatus == AppointmentStatuses.completed)
      .toList();

  List<AppointmentEntity> get cancelledAppointments => appointments
      .where((a) => a.normalizedStatus == AppointmentStatuses.cancelled)
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
        appointments[index] = appointments[index].copyWith(
          status: AppointmentStatuses.cancelled,
          statusUpdatedAt: DateTime.now(),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Không thể hủy lịch hẹn';
      notifyListeners();
      return false;
    }
  }

  // --- Advanced Booking Logic ---

  Future<bool> rescheduleAppointment(
      String id, DateTime newDate, String newTime) async {
    try {
      isLoading = true;
      notifyListeners();

      // Update appointment via repository
      await repository.rescheduleAppointment(id, newDate, newTime);

      final index = appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        appointments[index] = appointments[index].copyWith(
          dateTime: newDate,
          status: AppointmentStatuses.rescheduled,
          statusUpdatedAt: DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      errorMessage = 'Không thể đổi lịch hẹn';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> autoCancelIfUnpaid(String id) async {
    await Future.delayed(const Duration(minutes: 15));
    final appointment = appointments.firstWhere((a) => a.id == id);
    if (appointment.paymentStatus == AppointmentPaymentStatuses.pending ||
        appointment.paymentStatus == AppointmentPaymentStatuses.unpaid) {
      await cancelAppointment(id);
    }
  }

  Future<bool> lockSlot(String doctorId, DateTime date, String time) async {
    // Optimistic locking for slots
    try {
      return await repository.lockSlot(doctorId, date, time);
    } catch (e) {
      return false;
    }
  }
}

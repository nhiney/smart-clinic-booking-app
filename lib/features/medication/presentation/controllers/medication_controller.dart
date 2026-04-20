import 'package:flutter/material.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_intake.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../data/models/medication_model.dart';
import '../../data/services/medication_notification_service.dart';

class MedicationController extends ChangeNotifier {
  final MedicationRepository repository;

  MedicationController({required this.repository});

  List<MedicationEntity> medications = [];
  Map<String, double> adherenceRates = {};
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMedications(String patientId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      medications = await repository.getMedicationsByPatient(patientId);

      // Load adherence rates in background
      for (final med in medications) {
        repository.getAdherenceRate(med.id).then((rate) {
          adherenceRates[med.id] = rate;
          notifyListeners();
        });
      }
    } catch (e) {
      errorMessage = 'Failed to load medications';
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

      // Schedule local reminder
      if (created.isActive) {
        await MedicationNotificationService.scheduleMedicationReminder(created);
      }
      return true;
    } catch (e) {
      errorMessage = 'Failed to add medication';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedication(String id) async {
    try {
      await repository.deleteMedication(id);
      await MedicationNotificationService.cancelMedicationReminders(id);
      medications.removeWhere((m) => m.id == id);
      adherenceRates.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete medication';
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
        final updated = MedicationEntity(
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
        medications[index] = updated;

        if (isActive) {
          await MedicationNotificationService.scheduleMedicationReminder(updated);
        } else {
          await MedicationNotificationService.cancelMedicationReminders(id);
        }
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to update status';
      notifyListeners();
    }
  }

  Future<bool> recordIntake({
    required String medicationId,
    required String patientId,
    required bool wasTaken,
  }) async {
    try {
      await repository.recordIntake(
        medicationId: medicationId,
        patientId: patientId,
        scheduledAt: DateTime.now(),
        wasTaken: wasTaken,
      );
      // Refresh adherence
      final rate = await repository.getAdherenceRate(medicationId);
      adherenceRates[medicationId] = rate;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<MedicationIntake>> getIntakesForPeriod(String medicationId, {int days = 7}) async {
    final to = DateTime.now();
    final from = to.subtract(Duration(days: days));
    return repository.getIntakes(medicationId: medicationId, from: from, to: to);
  }

  double adherenceFor(String medicationId) => adherenceRates[medicationId] ?? 0;
}

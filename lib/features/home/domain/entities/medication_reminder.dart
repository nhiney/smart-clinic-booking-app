import 'package:equatable/equatable.dart';

/// Represents a medication reminder for the home screen.
class MedicationReminder extends Equatable {
  final String id;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final bool isTaken;
  final String? notes;

  const MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.isTaken,
    this.notes,
  });

  MedicationReminder copyWith({bool? isTaken}) {
    return MedicationReminder(
      id: id,
      medicationName: medicationName,
      dosage: dosage,
      scheduledTime: scheduledTime,
      isTaken: isTaken ?? this.isTaken,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [id, medicationName, dosage, scheduledTime, isTaken, notes];
}

import 'package:equatable/equatable.dart';

class MedicationPlanItem extends Equatable {
  final String name;
  final String dosage;
  final int timesPerDay;
  final int days;
  final String notes;

  const MedicationPlanItem({
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.days,
    this.notes = '',
  });

  MedicationPlanItem copyWith({
    String? name,
    String? dosage,
    int? timesPerDay,
    int? days,
    String? notes,
  }) {
    return MedicationPlanItem(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      days: days ?? this.days,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [name, dosage, timesPerDay, days, notes];
}

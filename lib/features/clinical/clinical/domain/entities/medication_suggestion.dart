import 'package:equatable/equatable.dart';

class MedicationSuggestion extends Equatable {
  final String name;
  final String dosage;
  final String frequency;
  final int days;

  const MedicationSuggestion({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.days,
  });

  @override
  List<Object?> get props => [name, dosage, frequency, days];
}

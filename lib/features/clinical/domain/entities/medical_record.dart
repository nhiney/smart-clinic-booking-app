import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final DateTime visitDate;
  final String doctorName;
  final String title;
  final String diagnosis;
  final String? note;

  const MedicalRecord({
    required this.id,
    required this.visitDate,
    required this.doctorName,
    required this.title,
    required this.diagnosis,
    this.note,
  });

  @override
  List<Object?> get props => [id, visitDate, doctorName, title, diagnosis, note];
}

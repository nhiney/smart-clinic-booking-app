import 'package:equatable/equatable.dart';

class DiagnosisSuggestion extends Equatable {
  final String code;
  final String name;
  final int confidence;

  const DiagnosisSuggestion({
    required this.code,
    required this.name,
    required this.confidence,
  });

  @override
  List<Object?> get props => [code, name, confidence];
}

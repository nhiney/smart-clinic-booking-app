import 'package:equatable/equatable.dart';

enum AssistantStatus { idle, listening, processing, speaking, error }

class AssistantState extends Equatable {
  final AssistantStatus status;
  final String currentText;
  final String responseText;

  const AssistantState({
    this.status = AssistantStatus.idle,
    this.currentText = '',
    this.responseText = '',
  });

  AssistantState copyWith({
    AssistantStatus? status,
    String? currentText,
    String? responseText,
  }) {
    return AssistantState(
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      responseText: responseText ?? this.responseText,
    );
  }

  @override
  List<Object?> get props => [status, currentText, responseText];
}

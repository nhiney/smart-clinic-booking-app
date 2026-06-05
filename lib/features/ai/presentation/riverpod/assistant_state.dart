import 'package:equatable/equatable.dart';

enum AssistantStatus { idle, listening, processing, speaking, error }

class ConversationTurn extends Equatable {
  final String userText;
  final String aiText;

  const ConversationTurn({required this.userText, required this.aiText});

  @override
  List<Object?> get props => [userText, aiText];
}

class AssistantState extends Equatable {
  final AssistantStatus status;
  final String currentText;
  final String responseText;
  final List<ConversationTurn> history;

  const AssistantState({
    this.status = AssistantStatus.idle,
    this.currentText = '',
    this.responseText = '',
    this.history = const [],
  });

  AssistantState copyWith({
    AssistantStatus? status,
    String? currentText,
    String? responseText,
    List<ConversationTurn>? history,
  }) {
    return AssistantState(
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      responseText: responseText ?? this.responseText,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [status, currentText, responseText, history];
}

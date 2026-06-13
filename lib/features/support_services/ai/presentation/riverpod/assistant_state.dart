import 'package:equatable/equatable.dart';

enum AssistantStatus { idle, listening, processing, speaking, error }

class ConversationTurn extends Equatable {
  final String userText;
  final String aiText;

  const ConversationTurn({required this.userText, required this.aiText});

  @override
  List<Object?> get props => [userText, aiText];
}

/// Extracted booking parameters from voice input.
class BookingIntentData extends Equatable {
  final String? specialty;
  final String? date;
  final String? timeSlot;

  const BookingIntentData({this.specialty, this.date, this.timeSlot});

  @override
  List<Object?> get props => [specialty, date, timeSlot];
}

class AssistantState extends Equatable {
  final AssistantStatus status;
  final String currentText;
  final String responseText;
  final List<ConversationTurn> history;
  /// Non-null when a booking intent was fully parsed and awaits UI confirmation.
  final BookingIntentData? pendingBooking;

  const AssistantState({
    this.status = AssistantStatus.idle,
    this.currentText = '',
    this.responseText = '',
    this.history = const [],
    this.pendingBooking,
  });

  AssistantState copyWith({
    AssistantStatus? status,
    String? currentText,
    String? responseText,
    List<ConversationTurn>? history,
    BookingIntentData? pendingBooking,
    bool clearPendingBooking = false,
  }) {
    return AssistantState(
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      responseText: responseText ?? this.responseText,
      history: history ?? this.history,
      pendingBooking: clearPendingBooking ? null : (pendingBooking ?? this.pendingBooking),
    );
  }

  @override
  List<Object?> get props => [status, currentText, responseText, history, pendingBooking];
}

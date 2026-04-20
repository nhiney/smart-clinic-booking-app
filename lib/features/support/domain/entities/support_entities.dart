import 'package:equatable/equatable.dart';

class FAQ extends Equatable {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FAQ({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [id, category, question, answer];
}

enum TicketStatus { open, inProgress, closed }
enum TicketPriority { low, medium, high }

class SupportTicket extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime? closedAt;
  final int? rating;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.status,
    this.priority = TicketPriority.medium,
    required this.createdAt,
    this.closedAt,
    this.rating,
  });

  @override
  List<Object?> get props => [id, userId, subject, status, priority, createdAt];
}

class SupportMessage extends Equatable {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const SupportMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, senderId, content, timestamp];
}

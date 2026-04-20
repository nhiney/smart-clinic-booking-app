import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

class FAQModel extends FAQ {
  const FAQModel({
    required super.id,
    required super.category,
    required super.question,
    required super.answer,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
    };
  }
}

class TicketModel extends SupportTicket {
  const TicketModel({
    required super.id,
    required super.userId,
    required super.subject,
    required super.status,
    super.priority = TicketPriority.medium,
    required super.createdAt,
    super.closedAt,
    super.rating,
  });

  factory TicketModel.fromFirestore(Map<String, dynamic> json, String id) {
    return TicketModel(
      id: id,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      status: TicketStatus.values.byName(json['status'] as String? ?? 'open'),
      priority: TicketPriority.values.byName(json['priority'] as String? ?? 'medium'),
      createdAt: (json['createdAt'] as dynamic).toDate(),
      closedAt: json['closedAt'] != null ? (json['closedAt'] as dynamic).toDate() : null,
      rating: json['rating'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'subject': subject,
        'status': status.name,
        'priority': priority.name,
        'createdAt': createdAt,
        'closedAt': closedAt,
        'rating': rating,
      };
}

class MessageModel extends SupportMessage {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

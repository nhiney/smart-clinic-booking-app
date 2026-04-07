import 'package:equatable/equatable.dart';

enum PaymentMethod { vnpay, momo, stripe }
enum PaymentStatus { pending, success, failed, refunded }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? description;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.description,
  });

  @override
  List<Object?> get props => [id, userId, amount, method, status, createdAt, description];
}

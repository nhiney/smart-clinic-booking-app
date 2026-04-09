import 'package:equatable/equatable.dart';

enum PaymentMethod { vnpay, momo, stripe }

enum PaymentStatus { pending, success, failed, refunded }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String? appointmentId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String? description;
  final String paymentRequestId;
  final int retryCount;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.appointmentId,
    required this.amount,
    this.currency = 'VND',
    required this.method,
    required this.status,
    required this.createdAt,
    this.description,
    required this.paymentRequestId,
    this.retryCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        appointmentId,
        amount,
        currency,
        method,
        status,
        createdAt,
        description,
        paymentRequestId,
        retryCount,
      ];
}

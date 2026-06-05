import 'package:equatable/equatable.dart';

enum PaymentMethod { vnpay, momo, stripe }

enum PaymentStatus { pending, success, failed, refunded }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String? appointmentId;
  final String? invoiceId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? description;
  final String paymentRequestId;
  final int retryCount;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.appointmentId,
    this.invoiceId,
    required this.amount,
    this.currency = 'VND',
    required this.method,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.description,
    required this.paymentRequestId,
    this.retryCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        appointmentId,
        invoiceId,
        amount,
        currency,
        method,
        status,
        createdAt,
        updatedAt,
        description,
        paymentRequestId,
        retryCount,
      ];
}

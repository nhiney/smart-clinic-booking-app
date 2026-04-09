import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    super.appointmentId,
    required super.amount,
    super.currency,
    required super.method,
    required super.status,
    required super.createdAt,
    super.description,
    required super.paymentRequestId,
    super.retryCount,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      appointmentId: data['appointmentId'] as String?,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'VND',
      method: PaymentMethod.values.firstWhere((e) => e.name == data['method']),
      status: PaymentStatus.values.firstWhere((e) => e.name == data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
      paymentRequestId: data['paymentRequestId'] ?? doc.id,
      retryCount: data['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'appointmentId': appointmentId,
      'amount': amount,
      'currency': currency,
      'method': method.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'paymentRequestId': paymentRequestId,
      'retryCount': retryCount,
    };
  }
}

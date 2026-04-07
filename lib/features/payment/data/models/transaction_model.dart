import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.method,
    required super.status,
    required super.createdAt,
    super.description,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere((e) => e.name == data['method']),
      status: PaymentStatus.values.firstWhere((e) => e.name == data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
    };
  }
}

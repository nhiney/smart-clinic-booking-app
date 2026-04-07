import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:smart_clinic_booking/features/payment/domain/repositories/payment_repository.dart';
import 'package:smart_clinic_booking/features/payment/data/models/transaction_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<TransactionEntity>> getTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      amount: transaction.amount,
      method: transaction.method,
      status: transaction.status,
      createdAt: transaction.createdAt,
      description: transaction.description,
    );
    await _firestore.collection('transactions').doc(transaction.id).set(model.toFirestore());
  }

  @override
  Future<void> updateTransactionStatus(String transactionId, PaymentStatus status) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'status': status.name,
    });
  }

  @override
  Future<void> requestRefund(String transactionId) async {
    await _firestore.collection('transactions').doc(transactionId).update({
      'status': 'refund_requested',
    });
  }
}

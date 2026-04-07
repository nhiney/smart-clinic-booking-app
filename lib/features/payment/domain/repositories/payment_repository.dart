import '../entities/transaction_entity.dart';

abstract class PaymentRepository {
  Future<List<TransactionEntity>> getTransactions(String userId);
  Future<void> createTransaction(TransactionEntity transaction);
  Future<void> updateTransactionStatus(String transactionId, PaymentStatus status);
  Future<void> requestRefund(String transactionId);
}

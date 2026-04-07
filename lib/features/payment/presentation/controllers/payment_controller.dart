import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:smart_clinic_booking/features/payment/domain/repositories/payment_repository.dart';
import 'package:smart_clinic_booking/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:smart_clinic_booking/features/payment/data/repositories/payment_service.dart';

class PaymentState {
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final TransactionEntity? currentTransaction;
  final String? error;

  PaymentState({
    this.isLoading = false,
    this.transactions = const [],
    this.currentTransaction,
    this.error,
  });

  PaymentState copyWith({
    bool? isLoading,
    List<TransactionEntity>? transactions,
    TransactionEntity? currentTransaction,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      error: error,
    );
  }
}

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepositoryImpl());
final paymentServiceProvider = Provider((ref) => PaymentService());

final paymentControllerProvider = StateNotifierProvider<PaymentController, PaymentState>((ref) {
  return PaymentController(
    repository: ref.watch(paymentRepositoryProvider),
    service: ref.watch(paymentServiceProvider),
  );
});

class PaymentController extends StateNotifier<PaymentState> {
  final PaymentRepository repository;
  final PaymentService service;

  PaymentController({required this.repository, required this.service}) : super(PaymentState());

  Future<void> fetchTransactions(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await repository.getTransactions(userId);
      state = state.copyWith(isLoading: false, transactions: transactions);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PaymentStatus> pay({
    required String userId,
    required double amount,
    required PaymentMethod method,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final transactionId = service.generateTransactionId();
    
    final transaction = TransactionEntity(
      id: transactionId,
      userId: userId,
      amount: amount,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      description: description,
    );

    try {
      await repository.createTransaction(transaction);
      final status = await service.processPayment(method, amount);
      await repository.updateTransactionStatus(transactionId, status);
      
      final updatedTransaction = TransactionEntity(
        id: transactionId,
        userId: userId,
        amount: amount,
        method: method,
        status: status,
        createdAt: transaction.createdAt,
        description: description,
      );
      
      state = state.copyWith(isLoading: false, currentTransaction: updatedTransaction);
      return status;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return PaymentStatus.failed;
    }
  }

  Future<void> refund(String transactionId) async {
    try {
      await repository.requestRefund(transactionId);
      // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

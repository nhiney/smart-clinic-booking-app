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

final paymentRepositoryProvider =
    Provider<PaymentRepository>((ref) => PaymentRepositoryImpl());
final paymentServiceProvider = Provider((ref) => PaymentService());

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, PaymentState>((ref) {
  return PaymentController(
    repository: ref.watch(paymentRepositoryProvider),
    service: ref.watch(paymentServiceProvider),
  );
});

class PaymentController extends StateNotifier<PaymentState> {
  final PaymentRepository repository;
  final PaymentService service;

  PaymentController({required this.repository, required this.service})
      : super(PaymentState());

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
    String? appointmentId,
    String? description,
    String? paymentRequestId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final transactionId = service.generateTransactionId();
    final requestId = paymentRequestId ?? service.generatePaymentRequestId();

    final transaction = TransactionEntity(
      id: transactionId,
      userId: userId,
      appointmentId: appointmentId,
      amount: amount,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      description: description,
      paymentRequestId: requestId,
    );

    try {
      // 1. Create pending transaction on Firestore
      await repository.createTransaction(transaction);

      // 2. Simulate payment gateway process
      final status = await service.simulatePayment();

      // 3. Update Firestore status
      await repository.updateTransactionStatus(transactionId, status);

      // 4. Refresh transaction list
      await fetchTransactions(userId);

      final updatedTransaction = TransactionEntity(
        id: transactionId,
        userId: userId,
        appointmentId: appointmentId,
        amount: amount,
        method: method,
        status: status,
        createdAt: transaction.createdAt,
        description: description,
        paymentRequestId: requestId,
      );

      state = state.copyWith(
          isLoading: false, currentTransaction: updatedTransaction);
      return status;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return PaymentStatus.failed;
    }
  }

  Future<void> refund(String userId, String transactionId) async {
    state = state.copyWith(isLoading: true);
    try {
      await repository.requestRefund(transactionId);
      await fetchTransactions(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

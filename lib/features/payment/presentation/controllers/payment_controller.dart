import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:smart_clinic_booking/features/payment/domain/repositories/payment_repository.dart';
import 'package:smart_clinic_booking/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:smart_clinic_booking/features/payment/data/repositories/payment_service.dart';
import 'package:smart_clinic_booking/features/invoice/presentation/controllers/invoice_controller.dart';
import 'package:smart_clinic_booking/features/invoice/domain/entities/invoice_entity.dart';

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
    invoiceController: ref.read(invoiceControllerProvider.notifier),
  );
});

class PaymentController extends StateNotifier<PaymentState> {
  final PaymentRepository repository;
  final PaymentService service;
  final InvoiceController invoiceController;

  PaymentController({
    required this.repository,
    required this.service,
    required this.invoiceController,
  }) : super(PaymentState());

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
    String? invoiceId,
    String? description,
    String? paymentRequestId,
    List<InvoiceItem>? invoiceItems,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final transactionId = service.generateTransactionId();
    final requestId = paymentRequestId ?? service.generatePaymentRequestId();

    final transaction = TransactionEntity(
      id: transactionId,
      userId: userId,
      appointmentId: appointmentId,
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      description: description,
      paymentRequestId: requestId,
    );

    try {
      await repository.createTransaction(transaction);

      final status = await service.simulatePayment();

      await repository.updateTransactionStatus(transactionId, status);

      if (status == PaymentStatus.success) {
        // Update existing invoice if invoiceId provided
        if (invoiceId != null) {
          await invoiceController.markInvoicePaid(invoiceId, paymentId: transactionId);
        }

        // Auto-create invoice when paying from appointment (no pre-existing invoice)
        if (appointmentId != null && invoiceId == null) {
          final items = invoiceItems ??
              [
                InvoiceItem(
                  name: description ?? 'Phí khám bệnh',
                  price: amount,
                  quantity: 1,
                )
              ];
          await invoiceController.createInvoiceForAppointment(
            userId: userId,
            appointmentId: appointmentId,
            services: items,
            total: amount,
            paymentId: transactionId,
          );
        }
      }

      await fetchTransactions(userId);

      final updatedTransaction = TransactionEntity(
        id: transactionId,
        userId: userId,
        appointmentId: appointmentId,
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        status: status,
        createdAt: transaction.createdAt,
        updatedAt: DateTime.now(),
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

      // Also revert invoice status if linked
      final tx = state.transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => state.transactions.first,
      );
      if (tx.invoiceId != null) {
        await invoiceController.markInvoicePaid(tx.invoiceId!, paymentId: null);
      }

      await fetchTransactions(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

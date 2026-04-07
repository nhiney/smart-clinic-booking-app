import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../data/repositories/invoice_repository_impl.dart';

class InvoiceState {
  final bool isLoading;
  final List<InvoiceEntity> invoices;
  final InvoiceEntity? selectedInvoice;
  final String? error;

  InvoiceState({
    this.isLoading = false,
    this.invoices = const [],
    this.selectedInvoice,
    this.error,
  });

  InvoiceState copyWith({
    bool? isLoading,
    List<InvoiceEntity>? invoices,
    InvoiceEntity? selectedInvoice,
    String? error,
  }) {
    return InvoiceState(
      isLoading: isLoading ?? this.isLoading,
      invoices: invoices ?? this.invoices,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      error: error,
    );
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) => InvoiceRepositoryImpl());

final invoiceControllerProvider = StateNotifierProvider<InvoiceController, InvoiceState>((ref) {
  return InvoiceController(repository: ref.watch(invoiceRepositoryProvider));
});

class InvoiceController extends StateNotifier<InvoiceState> {
  final InvoiceRepository repository;

  InvoiceController({required this.repository}) : super(InvoiceState());

  Future<void> fetchInvoices(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoices = await repository.getInvoices(userId);
      state = state.copyWith(isLoading: false, invoices: invoices);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchInvoiceDetail(String invoiceId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoice = await repository.getInvoiceDetail(invoiceId);
      state = state.copyWith(isLoading: false, selectedInvoice: invoice);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

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

  Future<void> markInvoicePaid(String invoiceId, {String? paymentId}) async {
    try {
      await repository.updateInvoiceStatus(invoiceId, 'paid', paymentId: paymentId);
      final updatedList = state.invoices.map((inv) {
        if (inv.id == invoiceId) {
          return InvoiceEntity(
            id: inv.id,
            userId: inv.userId,
            services: inv.services,
            total: inv.total,
            paymentId: paymentId ?? inv.paymentId,
            status: 'paid',
            createdAt: inv.createdAt,
          );
        }
        return inv;
      }).toList();
      state = state.copyWith(invoices: updatedList);
    } catch (_) {}
  }

  Future<String?> createInvoiceForAppointment({
    required String userId,
    required String appointmentId,
    required List<InvoiceItem> services,
    required double total,
    required String paymentId,
  }) async {
    try {
      final invoice = InvoiceEntity(
        id: 'INV${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        services: services,
        total: total,
        paymentId: paymentId,
        status: 'paid',
        createdAt: DateTime.now(),
      );
      final id = await repository.createInvoice(invoice);
      return id;
    } catch (_) {
      return null;
    }
  }
}

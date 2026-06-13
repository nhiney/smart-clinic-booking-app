import '../entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices(String userId);
  Future<InvoiceEntity> getInvoiceDetail(String invoiceId);
  Future<void> updateInvoiceStatus(String invoiceId, String status, {String? paymentId});
  Future<String> createInvoice(InvoiceEntity invoice);
}

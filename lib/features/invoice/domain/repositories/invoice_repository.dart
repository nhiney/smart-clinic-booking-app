import '../entities/invoice_entity.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceEntity>> getInvoices(String userId);
  Future<InvoiceEntity> getInvoiceDetail(String invoiceId);
}

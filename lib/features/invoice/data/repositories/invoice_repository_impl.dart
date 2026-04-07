import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/invoice/domain/entities/invoice_entity.dart';
import 'package:smart_clinic_booking/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:smart_clinic_booking/features/invoice/data/models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<InvoiceEntity>> getInvoices(String userId) async {
    final snapshot = await _firestore
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => InvoiceModel.fromFirestore(doc)).toList();
  }

  @override
  Future<InvoiceEntity> getInvoiceDetail(String invoiceId) async {
    final doc = await _firestore.collection('invoices').doc(invoiceId).get();
    return InvoiceModel.fromFirestore(doc);
  }
}

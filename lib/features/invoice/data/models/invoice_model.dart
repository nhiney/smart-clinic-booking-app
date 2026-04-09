import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/invoice/domain/entities/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.userId,
    required super.services,
    required super.total,
    required super.paymentId,
    required super.status,
    required super.createdAt,
  });

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvoiceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      services: (data['services'] as List).map((i) => InvoiceItem(
        name: i['name'],
        price: (i['price'] as num).toDouble(),
        quantity: i['quantity'] ?? 1,
      )).toList(),
      total: (data['total'] as num).toDouble(),
      paymentId: data['paymentId'] ?? '',
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'services': services.map((i) => {
        'name': i.name,
        'price': i.price,
        'quantity': i.quantity,
      }).toList(),
      'total': total,
      'paymentId': paymentId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

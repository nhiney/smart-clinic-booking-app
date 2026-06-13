import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String name;
  final double price;
  final int quantity;

  const InvoiceItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [name, price, quantity];
}

class InvoiceEntity extends Equatable {
  final String id;
  final String userId;
  final List<InvoiceItem> services;
  final double total;
  final String paymentId;
  final String status;
  final DateTime createdAt;

  const InvoiceEntity({
    required this.id,
    required this.userId,
    required this.services,
    required this.total,
    required this.paymentId,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, services, total, paymentId, status, createdAt];
}

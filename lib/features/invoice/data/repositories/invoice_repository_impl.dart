import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/invoice/domain/entities/invoice_entity.dart';
import 'package:smart_clinic_booking/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:smart_clinic_booking/features/invoice/data/models/invoice_model.dart';

import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SQLiteHelper _sqlite = SQLiteHelper.instance;

  @override
  Future<List<InvoiceEntity>> getInvoices(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final invoices = snapshot.docs.map((doc) => InvoiceModel.fromFirestore(doc)).toList();

      final db = await _sqlite.database;
      await db.transaction((txn) async {
        for (final i in invoices) {
          await txn.insert(
            'invoices_cache',
            {
              'id': i.id,
              'userId': i.userId,
              'data': jsonEncode(InvoiceModel(
                id: i.id,
                userId: i.userId,
                services: i.services,
                total: i.total,
                paymentId: i.paymentId,
                status: i.status,
                createdAt: i.createdAt,
              ).toFirestore()..['createdAt'] = i.createdAt.toIso8601String()),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return invoices;
    } catch (e) {
      final db = await _sqlite.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'invoices_cache',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return maps.map((m) {
        final data = jsonDecode(m['data']);
        return InvoiceModel(
          id: m['id'],
          userId: m['userId'],
          services: (data['services'] as List)
              .map((i) => InvoiceItem(
                    name: i['name'],
                    price: (i['price'] as num).toDouble(),
                    quantity: i['quantity'] ?? 1,
                  ))
              .toList(),
          total: (data['total'] as num).toDouble(),
          paymentId: data['paymentId'] ?? '',
          status: data['status'] ?? '',
          createdAt: DateTime.parse(data['createdAt']),
        );
      }).toList();
    }
  }

  @override
  Future<InvoiceEntity> getInvoiceDetail(String invoiceId) async {
    try {
      final doc = await _firestore.collection('invoices').doc(invoiceId).get();
      return InvoiceModel.fromFirestore(doc);
    } catch (e) {
      final db = await _sqlite.database;
      final List<Map<String, dynamic>> results = await db.query(
        'invoices_cache',
        where: 'id = ?',
        whereArgs: [invoiceId],
      );

      if (results.isNotEmpty) {
        final m = results.first;
        final data = jsonDecode(m['data']);
        return InvoiceModel(
          id: m['id'],
          userId: m['userId'],
          services: (data['services'] as List)
              .map((i) => InvoiceItem(
                    name: i['name'],
                    price: (i['price'] as num).toDouble(),
                    quantity: i['quantity'] ?? 1,
                  ))
              .toList(),
          total: (data['total'] as num).toDouble(),
          paymentId: data['paymentId'] ?? '',
          status: data['status'] ?? '',
          createdAt: DateTime.parse(data['createdAt']),
        );
      }
      throw Exception("Invoice not found");
    }
  }

  @override
  Future<void> updateInvoiceStatus(String invoiceId, String status, {String? paymentId}) async {
    final update = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (paymentId != null) update['paymentId'] = paymentId;

    await _firestore.collection('invoices').doc(invoiceId).update(update);

    final db = await _sqlite.database;
    final results = await db.query('invoices_cache', where: 'id = ?', whereArgs: [invoiceId]);
    if (results.isNotEmpty) {
      final data = jsonDecode(results.first['data'] as String) as Map<String, dynamic>;
      data['status'] = status;
      if (paymentId != null) data['paymentId'] = paymentId;
      await db.update(
        'invoices_cache',
        {'data': jsonEncode(data)},
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    }
  }

  @override
  Future<String> createInvoice(InvoiceEntity invoice) async {
    final model = InvoiceModel(
      id: invoice.id,
      userId: invoice.userId,
      services: invoice.services,
      total: invoice.total,
      paymentId: invoice.paymentId,
      status: invoice.status,
      createdAt: invoice.createdAt,
    );

    final docRef = invoice.id.isNotEmpty
        ? _firestore.collection('invoices').doc(invoice.id)
        : _firestore.collection('invoices').doc();

    await docRef.set(model.toFirestore());

    final db = await _sqlite.database;
    await db.insert(
      'invoices_cache',
      {
        'id': docRef.id,
        'userId': invoice.userId,
        'data': jsonEncode(model.toFirestore()..['createdAt'] = invoice.createdAt.toIso8601String()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return docRef.id;
  }
}

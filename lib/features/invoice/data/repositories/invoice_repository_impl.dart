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
      
      // Cache to SQLite
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
      // Fallback to SQLite
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
          services: (data['services'] as List).map((i) => InvoiceItem(
            name: i['name'],
            price: (i['price'] as num).toDouble(),
            quantity: i['quantity'] ?? 1,
          )).toList(),
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
      // Try local cache
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
          services: (data['services'] as List).map((i) => InvoiceItem(
            name: i['name'],
            price: (i['price'] as num).toDouble(),
            quantity: i['quantity'] ?? 1,
          )).toList(),
          total: (data['total'] as num).toDouble(),
          paymentId: data['paymentId'] ?? '',
          status: data['status'] ?? '',
          createdAt: DateTime.parse(data['createdAt']),
        );
      }
      throw Exception("Invoice not found");
    }
  }
}

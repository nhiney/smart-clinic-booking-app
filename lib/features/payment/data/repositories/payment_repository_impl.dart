import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_clinic_booking/features/payment/domain/entities/transaction_entity.dart';
import 'package:smart_clinic_booking/features/payment/domain/repositories/payment_repository.dart';
import 'package:smart_clinic_booking/features/payment/data/models/transaction_model.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SQLiteHelper _sqlite = SQLiteHelper.instance;

  @override
  Future<List<TransactionEntity>> getTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      // Cache to SQLite
      final db = await _sqlite.database;
      await db.transaction((txn) async {
        for (final t in transactions) {
          await txn.insert(
            'transactions_cache',
            {
              'id': t.id,
              'userId': t.userId,
              'data': jsonEncode(t.toFirestore()
                ..['createdAt'] = t.createdAt.toIso8601String()),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return transactions;
    } catch (e) {
      // Fallback to SQLite if offline
      final db = await _sqlite.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions_cache',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      return maps.map((m) {
        final data = jsonDecode(m['data']);
        return TransactionModel(
          id: m['id'],
          userId: m['userId'],
          appointmentId: data['appointmentId'],
          amount: (data['amount'] as num).toDouble(),
          currency: data['currency'] ?? 'VND',
          method:
              PaymentMethod.values.firstWhere((e) => e.name == data['method']),
          status:
              PaymentStatus.values.firstWhere((e) => e.name == data['status']),
          createdAt: DateTime.parse(data['createdAt']),
          description: data['description'],
          paymentRequestId: data['paymentRequestId'] ?? m['id'],
          retryCount: data['retryCount'] ?? 0,
        );
      }).toList();
    }
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    final existing = await _firestore
        .collection('payments')
        .where('paymentRequestId', isEqualTo: transaction.paymentRequestId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    final model = TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      appointmentId: transaction.appointmentId,
      amount: transaction.amount,
      currency: transaction.currency,
      method: transaction.method,
      status: transaction.status,
      createdAt: transaction.createdAt,
      description: transaction.description,
      paymentRequestId: transaction.paymentRequestId,
      retryCount: transaction.retryCount,
    );

    // Save to Firestore
    await _firestore
        .collection('payments')
        .doc(transaction.id)
        .set(model.toFirestore());

    // Cache to SQLite
    final db = await _sqlite.database;
    await db.insert(
      'transactions_cache',
      {
        'id': transaction.id,
        'userId': transaction.userId,
        'data': jsonEncode(model.toFirestore()
          ..['createdAt'] = transaction.createdAt.toIso8601String()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTransactionStatus(
      String transactionId, PaymentStatus status) async {
    await _firestore.collection('payments').doc(transactionId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update SQLite cache
    final db = await _sqlite.database;
    final List<Map<String, dynamic>> results = await db.query(
      'transactions_cache',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (results.isNotEmpty) {
      final data = jsonDecode(results.first['data']);
      data['status'] = status.name;
      await db.update(
        'transactions_cache',
        {'data': jsonEncode(data)},
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    }
  }

  @override
  Future<void> requestRefund(String transactionId) async {
    final doc =
        await _firestore.collection('payments').doc(transactionId).get();
    if (doc.exists) {
      final status = doc.data()?['status'];
      if (status == PaymentStatus.success.name) {
        await updateTransactionStatus(transactionId, PaymentStatus.refunded);
      }
    }
  }
}

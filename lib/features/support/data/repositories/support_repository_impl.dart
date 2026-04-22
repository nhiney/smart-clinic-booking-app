import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:smart_clinic_booking/core/error/failure.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';
import 'package:smart_clinic_booking/features/support/domain/repositories/support_repository.dart';
import 'package:smart_clinic_booking/features/support/data/models/support_models.dart';
import 'package:smart_clinic_booking/features/ai/data/services/gemini_ai_service.dart';

class SupportRepositoryImpl implements SupportRepository {
  final FirebaseFirestore _firestore;
  final SQLiteHelper _sqliteHelper;

  SupportRepositoryImpl({
    FirebaseFirestore? firestore,
    SQLiteHelper? sqliteHelper,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _sqliteHelper = sqliteHelper ?? SQLiteHelper.instance;

  @override
  Future<Either<Failure, List<FAQ>>> getFAQs({String? category, String? query}) async {
    try {
      // 1. Try Firestore first
      final snapshots = await _firestore.collection('faqs').get();
      
      // Map Firestore to Models
      final faqsMapped = snapshots.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FAQModel.fromJson(data);
      }).toList();

      // 2. Cache to SQLite
      await _cacheFAQs(faqsMapped);

      return Right(_filterFAQs(faqsMapped, category, query));
    } catch (e) {
      // 3. Fallback to SQLite Cache
      final cachedFAQs = await _getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        return Right(_filterFAQs(cachedFAQs, category, query));
      }
      return Left(ServerFailure(message: 'Không thể tải FAQ: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SupportTicket>>> getUserTickets(String userId) async {
    try {
      final snapshots = await _firestore
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return Right(snapshots.docs
          .map((doc) => TicketModel.fromFirestore(doc.data(), doc.id))
          .toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể tải danh sách ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createTicket(
    String userId,
    String subject, {
    TicketPriority priority = TicketPriority.medium,
  }) async {
    try {
      final docRef = await _firestore.collection('support_tickets').add({
        'userId': userId,
        'subject': subject,
        'status': 'open',
        'priority': priority.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> closeTicket(String ticketId, {int? rating}) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
        if (rating != null) 'rating': rating,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to close ticket: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getAiFaqAnswer(String question) async {
    try {
      final gemini = GeminiAiService();
      final response = await gemini.generateResponse(
        message: 'Answer this clinic support question concisely (under 100 words): $question',
        history: [],
        userContext: 'Patient support chatbot for ICare clinic',
      );
      return Right(response.content);
    } catch (e) {
      return Left(ServerFailure(message: 'AI answer unavailable: $e'));
    }
  }

  @override
  Stream<List<SupportMessage>> streamMessages(String ticketId) {
    return _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map<SupportMessage>((doc) => MessageModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<Either<Failure, void>> sendMessage(String ticketId, String senderId, String content) async {
    try {
      await _firestore
          .collection('support_tickets')
          .doc(ticketId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Gửi tin nhắn thất bại: $e'));
    }
  }

  // --- Helper Methods ---

  List<FAQ> _filterFAQs(List<FAQ> faqs, String? category, String? query) {
    var result = faqs;
    if (category != null && category.isNotEmpty) {
      result = result.where((faq) => faq.category == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((faq) =>
          faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  Future<void> _cacheFAQs(List<FAQModel> faqs) async {
    final db = await _sqliteHelper.database;
    final batch = db.batch();
    batch.delete('faq_cache');
    for (final FAQModel faq in faqs) {
      batch.insert('faq_cache', {
        'id': faq.id,
        'category': faq.category,
        'data': jsonEncode(faq.toJson()),
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<FAQ>> _getCachedFAQs() async {
    final db = await _sqliteHelper.database;
    final maps = await db.query('faq_cache');
    return maps.map<FAQ>((map) {
      final data = jsonDecode(map['data'] as String);
      return FAQModel.fromJson(data);
    }).toList();
  }
}

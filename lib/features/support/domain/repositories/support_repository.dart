import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/support_entities.dart';

abstract class SupportRepository {
  Future<Either<Failure, List<FAQ>>> getFAQs({String? category, String? query});
  Future<Either<Failure, List<SupportTicket>>> getUserTickets(String userId);
  Future<Either<Failure, String>> createTicket(
    String userId,
    String subject, {
    TicketPriority priority,
  });
  Future<Either<Failure, void>> closeTicket(String ticketId, {int? rating});
  Stream<List<SupportMessage>> streamMessages(String ticketId);
  Future<Either<Failure, void>> sendMessage(String ticketId, String senderId, String content);
  Future<Either<Failure, String>> getAiFaqAnswer(String question);
}

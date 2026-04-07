import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/support_entities.dart';
import '../repositories/support_repository.dart';

class GetFAQsParams {
  final String? category;
  final String? query;
  GetFAQsParams({this.category, this.query});
}

class GetFAQsUseCase implements UseCase<List<FAQ>, GetFAQsParams> {
  final SupportRepository repository;
  GetFAQsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FAQ>>> call(GetFAQsParams params) {
    return repository.getFAQs(category: params.category, query: params.query);
  }
}

class GetTicketsUseCase implements UseCase<List<SupportTicket>, String> {
  final SupportRepository repository;
  GetTicketsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SupportTicket>>> call(String userId) {
    return repository.getUserTickets(userId);
  }
}

class CreateTicketParams {
  final String userId;
  final String subject;
  CreateTicketParams({required this.userId, required this.subject});
}

class CreateTicketUseCase implements UseCase<String, CreateTicketParams> {
  final SupportRepository repository;
  CreateTicketUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateTicketParams params) {
    return repository.createTicket(params.userId, params.subject);
  }
}

class SendMessageParams {
  final String ticketId;
  final String senderId;
  final String content;
  SendMessageParams({required this.ticketId, required this.senderId, required this.content});
}

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final SupportRepository repository;
  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) {
    return repository.sendMessage(params.ticketId, params.senderId, params.content);
  }
}

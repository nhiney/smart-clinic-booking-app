import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/ai_repository.dart';

class ChatWithAIUseCase implements UseCase<ChatMessage, ChatWithAIParams> {
  final AIRepository repository;

  ChatWithAIUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessage>> call(ChatWithAIParams params) async {
    return await repository.chat(params.message, params.history);
  }
}

class ChatWithAIParams extends Equatable {
  final String message;
  final List<ChatMessage> history;

  const ChatWithAIParams({
    required this.message,
    required this.history,
  });

  @override
  List<Object?> get props => [message, history];
}

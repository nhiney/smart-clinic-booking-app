import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/chat_message.dart';

abstract class AIRepository {
  /// Sends a message and receives an AI response, maintaining context via [history].
  Future<Either<Failure, ChatMessage>> chat(String message, List<ChatMessage> history);
  
  /// Analyzes the symptoms and returns an initial triage suggestion.
  Future<Either<Failure, String>> analyzeSymptoms(String symptoms);
  
  /// Recommends a specific doctor specialty based on the provided symptoms.
  Future<Either<Failure, String>> recommendDoctor(String symptoms);
}

import 'package:dartz/dartz.dart';
import '../error/failure.dart';

/// Base UseCase interface for all use cases in the domain layer.
/// Uses the Either pattern: Left = Failure, Right = Success.
/// [Type] is the return type on success.
/// [Params] is the input parameters type. Use [NoParams] for no params.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Placeholder for use cases that take no parameters.
class NoParams {
  const NoParams();
}

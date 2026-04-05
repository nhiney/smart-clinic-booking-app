import 'package:equatable/equatable.dart';

/// Base failure class for the Either/Result pattern.
/// All domain-layer errors extend this class.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failures originating from remote data sources (Firebase, REST API).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Failures originating from local cache (Hive, SharedPreferences).
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failures.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Firebase-specific failures.
class FirebaseFailure extends Failure {
  const FirebaseFailure({required super.message, super.code});
}

/// Authentication failures.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Input validation failures.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Permission/authorization failures (RBAC).
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
  });
}

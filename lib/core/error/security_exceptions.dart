abstract class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);
}

/// 401 - Unauthenticated
class UnauthorizedException extends SecurityException {
  const UnauthorizedException([String message = 'User not authenticated']) : super(message);
}

/// 403 - Insufficient Permissions
class ForbiddenException extends SecurityException {
  const ForbiddenException([String message = 'Insufficient permissions to perform this action']) : super(message);
}

import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

/// States cho AuthBloc — quản lý trạng thái xác thực toàn cục.
///
/// State machine:
/// ```
/// AuthInitial → AuthLoading → AuthAuthenticated
///                           → AuthUnauthenticated
///                           → AuthError
/// AuthAuthenticated → AuthLoading (logout) → AuthUnauthenticated
/// AuthAuthenticated → AuthTokenExpired → AuthLoading (refresh) → AuthAuthenticated
/// ```
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu — chưa kiểm tra auth.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Đang xử lý (đăng nhập / đăng xuất / refresh).
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Đã xác thực thành công — user đang đăng nhập.
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final bool isSessionRestored; // true nếu restore từ saved session

  const AuthAuthenticated({
    required this.user,
    this.isSessionRestored = false,
  });

  @override
  List<Object?> get props => [user, isSessionRestored];
}

/// Chưa xác thực — user cần đăng nhập.
class AuthUnauthenticated extends AuthState {
  final String? reason; // Lý do (logout, session expired, etc.)

  const AuthUnauthenticated({this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Token đã hết hạn — cần refresh hoặc login lại.
class AuthTokenExpired extends AuthState {
  const AuthTokenExpired();
}

/// Lỗi xác thực.
class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

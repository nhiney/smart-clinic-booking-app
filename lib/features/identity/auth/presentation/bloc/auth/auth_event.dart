import 'package:equatable/equatable.dart';

/// Events cho AuthBloc — quản lý trạng thái xác thực toàn cục.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kiểm tra trạng thái auth khi app khởi động.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Đăng nhập bằng email/phone + password.
class AuthLoginRequested extends AuthEvent {
  final String credential;
  final String password;
  final String? requiredRole;

  const AuthLoginRequested({
    required this.credential,
    required this.password,
    this.requiredRole,
  });

  @override
  List<Object?> get props => [credential, password, requiredRole];
}

/// Đăng nhập bằng sinh trắc học.
class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

/// Đăng nhập bằng QR Code.
class AuthQrLoginRequested extends AuthEvent {
  final String qrToken;

  const AuthQrLoginRequested({required this.qrToken});

  @override
  List<Object?> get props => [qrToken];
}

/// Đăng xuất.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Refresh token (tự động hoặc thủ công).
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}

/// Session được restore từ Secure Storage.
class AuthSessionRestored extends AuthEvent {
  const AuthSessionRestored();
}

/// User profile đã thay đổi (cập nhật từ Firestore).
class AuthUserUpdated extends AuthEvent {
  final dynamic user; // UserEntity
  const AuthUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

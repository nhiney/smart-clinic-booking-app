import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/refresh_token_usecase.dart';
import 'package:smart_clinic_booking/core/security/session_manager.dart';
import 'package:smart_clinic_booking/core/security/secure_token_storage.dart';

import './auth_event.dart';
import './auth_state.dart';

/// BLoC quản lý trạng thái xác thực toàn cục của ứng dụng.
///
/// ### Responsibilities:
/// - Kiểm tra auth state khi app khởi động (session restore)
/// - Xử lý Login / Logout flow
/// - Tự động refresh token khi sắp hết hạn
/// - Lắng nghe Firebase auth state changes
///
/// ### Sử dụng trong widget tree:
/// ```dart
/// BlocProvider<AuthBloc>(
///   create: (_) => AuthBloc(...)..add(const AuthCheckRequested()),
/// )
/// ```
///
/// ### Lắng nghe state:
/// ```dart
/// BlocListener<AuthBloc, AuthState>(
///   listener: (context, state) {
///     if (state is AuthUnauthenticated) {
///       GoRouter.of(context).go('/login');
///     }
///   },
/// )
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final AuthRepository authRepository;

  final SessionManager _sessionManager = SessionManager.instance;
  final SecureTokenStorage _tokenStorage = SecureTokenStorage.instance;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({
    required this.loginWithEmailUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.refreshTokenUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
    on<AuthQrLoginRequested>(_onQrLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthSessionRestored>(_onSessionRestored);
    on<AuthUserUpdated>(_onUserUpdated);

    // Lắng nghe Firebase auth state changes
    _initAuthStateListener();
  }

  // ── Auth State Listener ───────────────────────────────────────────

  void _initAuthStateListener() {
    _authSubscription?.cancel();
    _authSubscription = authRepository.onAuthStateChanged.listen(
      (user) {
        if (user != null && state is! AuthAuthenticated) {
          add(AuthUserUpdated(user));
        } else if (user == null && state is AuthAuthenticated) {
          add(const AuthLogoutRequested());
        }
      },
      onError: (error) {
        debugPrint('[AuthBloc] Auth stream error: $error');
      },
    );
  }

  // ── Event Handlers ────────────────────────────────────────────────

  /// Kiểm tra auth khi app khởi động.
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang kiểm tra phiên đăng nhập...'));

    try {
      // 1. Thử restore từ Firebase Auth + Firestore profile
      final user = await getCurrentUserUseCase();

      if (user != null) {
        // Lưu session vào Secure Storage
        await _tokenStorage.saveUserSession(SessionData(
          uid: user.id,
          role: user.role,
          email: user.email,
          name: user.name,
          tenantId: user.tenantId,
          savedAt: DateTime.now(),
        ));

        emit(AuthAuthenticated(user: user, isSessionRestored: true));
        debugPrint('[AuthBloc] ✅ Session restored cho: ${user.name}');
        return;
      }

      // 2. Không có session hợp lệ
      emit(const AuthUnauthenticated(reason: 'Chưa đăng nhập'));
    } catch (e) {
      debugPrint('[AuthBloc] ❌ Auth check error: $e');
      emit(const AuthUnauthenticated(reason: 'Không thể kiểm tra phiên'));
    }
  }

  /// Đăng nhập bằng email/phone + password.
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang đăng nhập...'));

    try {
      final user = await loginWithEmailUseCase(
        event.credential,
        event.password,
        requiredRole: event.requiredRole,
      );

      // Lưu session
      await authRepository.saveSession(user);
      await _tokenStorage.saveUserSession(SessionData(
        uid: user.id,
        role: user.role,
        email: user.email,
        name: user.name,
        tenantId: user.tenantId,
        savedAt: DateTime.now(),
      ));

      // Khởi tạo session manager (auto token refresh)
      final firebaseUser = authRepository.getCurrentUser();
      if (firebaseUser != null) {
        // SessionManager sẽ được init từ AuthController
        debugPrint('[AuthBloc] ✅ Login thành công: ${user.name}');
      }

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(message: errorMsg));
    }
  }

  /// Đăng nhập bằng sinh trắc học.
  Future<void> _onBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang xác thực sinh trắc học...'));

    try {
      final user = await authRepository.loginWithBiometrics();

      await authRepository.saveSession(user);
      await _tokenStorage.saveUserSession(SessionData(
        uid: user.id,
        role: user.role,
        email: user.email,
        name: user.name,
        tenantId: user.tenantId,
        savedAt: DateTime.now(),
      ));

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(message: errorMsg));
    }
  }

  /// Đăng nhập bằng QR Code.
  Future<void> _onQrLoginRequested(
    AuthQrLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang xác thực mã QR...'));

    try {
      final user = await authRepository.signInWithQrToken(event.qrToken);

      await authRepository.saveSession(user);
      await _tokenStorage.saveUserSession(SessionData(
        uid: user.id,
        role: user.role,
        email: user.email,
        name: user.name,
        tenantId: user.tenantId,
        savedAt: DateTime.now(),
      ));

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(message: errorMsg));
    }
  }

  /// Đăng xuất.
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang đăng xuất...'));

    try {
      await logoutUseCase();
      await _sessionManager.terminateSession();
      await _tokenStorage.clearSession();

      emit(const AuthUnauthenticated(reason: 'Đã đăng xuất'));
      debugPrint('[AuthBloc] ✅ Logout thành công');
    } catch (e) {
      debugPrint('[AuthBloc] ❌ Logout error: $e');
      // Vẫn set unauthenticated dù logout lỗi
      emit(const AuthUnauthenticated(reason: 'Đã đăng xuất'));
    }
  }

  /// Refresh token.
  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final newToken = await refreshTokenUseCase();
      if (newToken == null) {
        debugPrint('[AuthBloc] ⚠️ Token refresh thất bại');
        emit(const AuthTokenExpired());
      } else {
        debugPrint('[AuthBloc] ✅ Token refreshed');
        // Không thay đổi state — vẫn giữ AuthAuthenticated
      }
    } catch (e) {
      debugPrint('[AuthBloc] ❌ Token refresh error: $e');
      emit(const AuthTokenExpired());
    }
  }

  /// Session được restore.
  Future<void> _onSessionRestored(
    AuthSessionRestored event,
    Emitter<AuthState> emit,
  ) async {
    // Trigger auth check
    add(const AuthCheckRequested());
  }

  /// User profile cập nhật (từ Firebase stream).
  Future<void> _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user is UserEntity) {
      final user = event.user as UserEntity;
      // Fetch full profile
      final profile = await authRepository.getUserProfile(user.id);
      if (profile != null) {
        emit(AuthAuthenticated(user: profile));
      }
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _sessionManager.dispose();
    return super.close();
  }
}

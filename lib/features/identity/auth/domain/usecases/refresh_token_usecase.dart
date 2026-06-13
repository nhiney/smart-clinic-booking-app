import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

/// UseCase tự động refresh Firebase ID Token.
///
/// Firebase ID Token có TTL = 1 giờ. UseCase này được gọi:
/// - Tự động bởi SessionManager (timer 55 phút)
/// - Thủ công khi nhận HTTP 401 từ server
/// - Khi app resume từ background
///
/// Returns token mới nếu refresh thành công, `null` nếu thất bại.
@lazySingleton
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  /// Refresh token. Returns token string mới hoặc `null`.
  Future<String?> call() async {
    try {
      return await repository.refreshToken();
    } catch (e) {
      return null;
    }
  }
}

import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase lấy thông tin user hiện tại từ session đã lưu.
///
/// Dùng khi app khởi động lại (cold start) để restore session
/// mà không cần user đăng nhập lại.
///
/// ### Flow:
/// 1. Kiểm tra Secure Storage có saved session
/// 2. Lấy UID từ session → fetch profile từ Firestore (hoặc cache)
/// 3. Return UserEntity nếu session hợp lệ, `null` nếu hết hạn
@lazySingleton
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Lấy user hiện tại.
  /// Returns `null` nếu chưa đăng nhập hoặc session hết hạn.
  Future<UserEntity?> call() async {
    try {
      // 1. Kiểm tra Firebase Auth trước
      final currentUser = repository.getCurrentUser();
      if (currentUser != null) {
        // 2. Fetch full profile từ Firestore
        final profile = await repository.getUserProfile(currentUser.id);
        return profile;
      }

      // 3. Kiểm tra saved session (offline fallback)
      final hasSession = await repository.hasSavedSession();
      if (!hasSession) return null;

      return currentUser;
    } catch (e) {
      // Session restoration failed silently
      return null;
    }
  }
}

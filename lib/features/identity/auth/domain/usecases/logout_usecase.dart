import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

/// UseCase cho luồng Đăng xuất.
///
/// Responsibilities:
/// - Gọi repository.logout() (Firebase signOut + clear Firestore session)
/// - Xoá tokens khỏi Secure Storage
/// - Xoá session data
///
/// Tuân thủ Single Responsibility: chỉ xử lý logout logic.
@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Thực thi logout.
  /// Throws [Exception] nếu có lỗi nghiêm trọng.
  Future<void> call() async {
    try {
      await repository.logout();
    } catch (e) {
      // Log nhưng vẫn rethrow — UI cần biết nếu logout thất bại
      rethrow;
    }
  }
}

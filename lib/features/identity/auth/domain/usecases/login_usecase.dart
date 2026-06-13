import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginWithEmailUseCase {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  Future<UserEntity> call(
    String email,
    String password, {
    String? requiredRole,
  }) async {
    return await repository.loginWithEmail(
      email,
      password,
      requiredRole: requiredRole,
    );
  }
}

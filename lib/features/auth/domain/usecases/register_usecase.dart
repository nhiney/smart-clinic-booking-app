import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(
    String name,
    String phone,
    String password, {
    String role = 'patient',
  }) async {
    return await repository.register(
      name,
      phone,
      password,
      role: role,
    );
  }
}

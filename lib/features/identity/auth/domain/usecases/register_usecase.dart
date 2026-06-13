import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String phone,
    required String role,
    String? email,
    String? password,
    String? tenantId,
  }) async {
    return await repository.register(
      name: name,
      phone: phone,
      role: role,
      email: email,
      password: password,
      tenantId: tenantId,
    );
  }
}

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
    required String password,
    required String role,
    String? hospitalId,
    String? idCardUrl,
    String? medicalCertUrl,
  }) async {
    return await repository.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
      hospitalId: hospitalId,
      idCardUrl: idCardUrl,
      medicalCertUrl: medicalCertUrl,
    );
  }
}

import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CreatePasswordUseCase {
  final AuthRepository repository;

  CreatePasswordUseCase(this.repository);

  Future<void> call(String phone, String password) async {
    return await repository.createPassword(phone, password);
  }
}

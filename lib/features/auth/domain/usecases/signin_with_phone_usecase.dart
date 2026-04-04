import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInWithPhoneUseCase {
  final AuthRepository repository;

  SignInWithPhoneUseCase(this.repository);

  Future<UserEntity> call(String verificationId, String smsCode, {String? displayName}) async {
    return await repository.signInWithPhone(verificationId, smsCode, displayName: displayName);
  }
}

import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class VerifyPhoneUseCase {
  final AuthRepository repository;

  VerifyPhoneUseCase(this.repository);

  Future<void> call(String phone, {
    required void Function(String verificationId) onCodeSent,
    required void Function() onAutoVerified,
    required void Function(String error) onError,
  }) async {
    return await repository.verifyPhone(
      phone,
      onCodeSent: onCodeSent,
      onAutoVerified: onAutoVerified,
      onError: onError,
    );
  }
}

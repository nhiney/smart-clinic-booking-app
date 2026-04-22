import '../repositories/kiosk_repository.dart';

class AuthenticateKioskUseCase {
  final IKioskRepository repository;

  AuthenticateKioskUseCase(this.repository);

  Future<void> call({required String email, required String password}) async {
    return await repository.authenticateKiosk(email, password);
  }
}

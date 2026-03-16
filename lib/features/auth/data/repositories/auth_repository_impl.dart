import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remoteDatasource.login(
      email: email,
      password: password,
    );

    final user = result.user!;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: '',
    );
  }

  @override
  Future<UserEntity> register(
    String name,
    String email,
    String password,
  ) async {
    final result = await remoteDatasource.register(
      name: name,
      email: email,
      password: password,
    );

    final user = result.user!;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: name,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDatasource.logout();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = remoteDatasource.getCurrentUser();

    if (user == null) return null;

    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: '',
    );
  }
}

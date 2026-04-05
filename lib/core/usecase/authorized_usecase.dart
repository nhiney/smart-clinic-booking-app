import 'package:dartz/dartz.dart';

import '../error/failure.dart';
import '../error/security_exceptions.dart';
import '../security/permission_manager.dart';
import '../security/auth_user.dart';
import '../security/resource_context.dart';

/// Base class for all UseCases that require explicit AppPermission and ABAC checks.
abstract class AuthorizedUseCase<Type, Params> {
  final PermissionManager _permissionManager;
  final AuthUser _currentUser; // Typically injected via service locator or passed from auth state
  
  AuthorizedUseCase(this._permissionManager, this._currentUser);

  /// Subclasses define their mandated permission
  AppPermission get requiredPermission;

  /// Subclasses build the context using parameters provided before execution to satisfy ABAC
  ResourceContext buildContext(Params params);

  /// Must be implemented by the child logic. Only executes if guard passes.
  Future<Either<Failure, Type>> execute(Params params);

  /// Core execution flow with the built-in security Guard.
  Future<Either<Failure, Type>> call(Params params) async {
    final context = buildContext(params);
    
    if (!_permissionManager.hasPermission(_currentUser, requiredPermission, context)) {
      // Access totally denied. Throw domain exception which UI catches and handles.
      throw const ForbiddenException();
    }
    
    // Proceed to standard execution inside the actual module.
    return await execute(params);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../permission_manager.dart';
import '../auth_user.dart';
import '../resource_context.dart';

/// Wraps widgets that require specific permissions.
/// A crucial piece for granular UI-level Role-Based and Attribute-Based rendering.
class RequirePermission extends StatelessWidget {
  final AppPermission permission;
  final ResourceContext? context;
  final Widget child;
  final Widget fallback;

  const RequirePermission({
    super.key,
    required this.permission,
    required this.child,
    this.context,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext childContext) {
    // Attempt to locate AuthUser & PermissionManager up the tree. 
    // This expects them to be provided via Provider, or alternatively by GetIt.
    try {
      final currentUser = childContext.watch<AuthUser>(); 
      final manager = childContext.read<PermissionManager>();

      if (manager.hasPermission(currentUser, permission, context)) {
        return child;
      }
      return fallback;
    } catch (e) {
      // If Auth/Security providers aren't found, safely fallback to protect the UI.
      debugPrint('[RequirePermission] Error locating auth context: $e');
      return fallback;
    }
  }
}

import 'package:injectable/injectable.dart';

import 'auth_user.dart';
import 'resource_context.dart';

/// The central authority for validating permissions based on Role and Context.
@lazySingleton
class PermissionManager {
  
  /// Validates if an [AuthUser] has [AppPermission] on a specific [ResourceContext].
  bool hasPermission(AuthUser user, AppPermission permission, [ResourceContext? context]) {
    // 1. Root level override: Super Admins can do anything
    if (user.role == AppRole.super_admin) return true;

    // 2. Global Status Guard: Pending users can strictly ONLY submit applications
    if (user.status == 'pending' && permission != AppPermission.submitKYCApplication) {
      return false;
    }

    // 3. Delegate to detailed ABAC checks
    switch (permission) {
      case AppPermission.updateMedicalRecord:
        return _canUpdateMedicalRecord(user, context);
        
      case AppPermission.viewAppointment:
        return _canViewAppointment(user, context);

      case AppPermission.viewMedicalRecord:
        return _canViewMedicalRecord(user, context);

      case AppPermission.viewKYCApplications:
      case AppPermission.approveDoctor:
        return _canManageKYC(user, context);

      case AppPermission.submitKYCApplication:
        // Already cleared by global guard if pending, or active user submitting another request.
        return true; 
        
      case AppPermission.createMedicalRecord:
      case AppPermission.createAppointment:
      case AppPermission.updateAppointment:
      case AppPermission.cancelAppointment:
      case AppPermission.viewDashboard:
        // Basic RBAC pass-through for now
        return true; 
        
      default:
        return false; // Strict default deny
    }
  }

  bool _canUpdateMedicalRecord(AuthUser user, ResourceContext? context) {
    if (user.role == AppRole.doctor) {
      // ABAC: A doctor can only update if they are the exact assigned doctor.
      return context?.doctorId != null && context?.doctorId == user.uid;
    }
    return false;
  }

  bool _canViewAppointment(AuthUser user, ResourceContext? context) {
    if (user.role == AppRole.hospital_manager) {
      // ABAC: A manager can only view appointments tied to their hospital's tenant ID.
      return context?.resourceTenantId != null && context?.resourceTenantId == user.tenantId;
    }
    if (user.role == AppRole.doctor) {
      return context?.doctorId == user.uid;
    }
    if (user.role == AppRole.patient) {
      return context?.resourceOwnerId == user.uid;
    }
    return false;
  }
  
  bool _canViewMedicalRecord(AuthUser user, ResourceContext? context) {
     if (user.role == AppRole.patient) {
       return context?.resourceOwnerId == user.uid;
     }
     if (user.role == AppRole.doctor) {
       return context?.doctorId == user.uid || context?.resourceTenantId == user.tenantId;
     }
     if (user.role == AppRole.hospital_manager) {
       return context?.resourceTenantId == user.tenantId;
     }
     return false;
  }

  bool _canManageKYC(AuthUser user, ResourceContext? context) {
    if (user.role == AppRole.hospital_manager) {
      // ABAC: Manager can only view/approve KYC aimed at their specific hospital
      return context?.resourceTenantId != null && context?.resourceTenantId == user.tenantId;
    }
    return false;
  }
}

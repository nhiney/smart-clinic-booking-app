import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/core/security/auth_user.dart';
import 'package:smart_clinic_booking/core/security/permission_manager.dart';
import 'package:smart_clinic_booking/core/security/resource_context.dart';

void main() {
  late PermissionManager permissionManager;

  setUp(() {
    permissionManager = PermissionManager();
  });

  group('KYC ABAC Authorization Test Checks', () {
    test('Hospital Manager should FAIL to view applications of a different tenant_id', () {
      final manager = const AuthUser(
          uid: 'manager_42', 
          role: AppRole.hospital_manager, 
          tenantId: 'HOSPITAL_A', 
          status: 'active'
      );
      
      // Context: application is requesting to join HOSPITAL_B
      final rivalHospitalContext = const ResourceContext(resourceTenantId: 'HOSPITAL_B');

      final result = permissionManager.hasPermission(
          manager, AppPermission.viewKYCApplications, rivalHospitalContext);

      // Verify the ABAC gate successfully drops the request.
      expect(result, isFalse);
    });

    test('Pending users MUST fail all actions EXCEPT submitting an application', () {
      final pendingDoctor = const AuthUser(
          uid: 'doc_pending', 
          role: AppRole.unverified, 
          status: 'pending' // Global Block
      );
      
      final context = const ResourceContext(doctorId: 'doc_pending');

      final canSubmit = permissionManager.hasPermission(
          pendingDoctor, AppPermission.submitKYCApplication, context);

      final canViewDashboard = permissionManager.hasPermission(
          pendingDoctor, AppPermission.viewDashboard, context);

      expect(canSubmit, isTrue);
      expect(canViewDashboard, isFalse); // Blocked globally by 'pending' gate
    });

    test('Active Hospital Manager CAN view applications directed at their own tenant_id', () {
      final manager = const AuthUser(
          uid: 'manager_11', 
          role: AppRole.hospital_manager, 
          tenantId: 'CLINIC_XYZ', 
          status: 'active'
      );
      
      // Context: application is requesting to join their specific clinic
      final clinicContext = const ResourceContext(resourceTenantId: 'CLINIC_XYZ');

      final result = permissionManager.hasPermission(
          manager, AppPermission.viewKYCApplications, clinicContext);

      expect(result, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/core/security/auth_user.dart';
import 'package:smart_clinic_booking/core/security/permission_manager.dart';
import 'package:smart_clinic_booking/core/security/resource_context.dart';

void main() {
  late PermissionManager permissionManager;

  setUp(() {
    permissionManager = PermissionManager();
  });

  group('PermissionManager RBAC/ABAC Tests', () {
    
    test('Super Admin should be ALLOWED to perform any action regardless of context', () {
      final admin = const AuthUser(uid: 'admin_1', role: AppRole.super_admin);
      final context = const ResourceContext(doctorId: 'doc_999');

      final result1 = permissionManager.hasPermission(admin, AppPermission.updateMedicalRecord, context);
      final result2 = permissionManager.hasPermission(admin, AppPermission.viewAppointment);

      expect(result1, isTrue);
      expect(result2, isTrue);
    });

    group('ABAC Authorization on updateMedicalRecord', () {
      
      test('Doctor should be ALLOWED to update their assigned patient record', () {
        final doctor = const AuthUser(uid: 'doc_123', role: AppRole.doctor);
        // Context specifies that doc_123 is the assigned doctor
        final context = const ResourceContext(doctorId: 'doc_123', resourceTenantId: 'tenant_A');

        final result = permissionManager.hasPermission(
            doctor, AppPermission.updateMedicalRecord, context);

        expect(result, isTrue);
      });

      test('Doctor should be FORBIDDEN to update another doctors patient record', () {
        final maliciousDoctor = const AuthUser(uid: 'doc_123', role: AppRole.doctor);
        // Attempting to modify a record explicitly assigned to a completely separate doctor
        final anotherDoctorsContext = const ResourceContext(doctorId: 'doc_456');

        final result = permissionManager.hasPermission(
            maliciousDoctor, AppPermission.updateMedicalRecord, anotherDoctorsContext);

        expect(result, isFalse); 
      });

      test('Patient should be FORBIDDEN to update their own medical record', () {
        final patient = const AuthUser(uid: 'pat_111', role: AppRole.patient);
        final context = const ResourceContext(resourceOwnerId: 'pat_111');

        final result = permissionManager.hasPermission(
            patient, AppPermission.updateMedicalRecord, context);

        expect(result, isFalse); 
      });
    });

    group('ABAC Authorization on viewAppointment', () {
      test('Hospital Manager should see appointments inside their tenant', () {
        final manager = const AuthUser(uid: 'mgr_9', role: AppRole.hospital_manager, tenantId: 'hosp_x');
        final sameHospitalContext = const ResourceContext(resourceTenantId: 'hosp_x');

        final result = permissionManager.hasPermission(
            manager, AppPermission.viewAppointment, sameHospitalContext);

        expect(result, isTrue);
      });

      test('Hospital Manager should NOT see appointments in another tenant', () {
        final manager = const AuthUser(uid: 'mgr_9', role: AppRole.hospital_manager, tenantId: 'hosp_x');
        final differentHospitalContext = const ResourceContext(resourceTenantId: 'hosp_other');

        final result = permissionManager.hasPermission(
            manager, AppPermission.viewAppointment, differentHospitalContext);

        expect(result, isFalse);
      });
    });
  });
}

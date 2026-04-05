// ignore_for_file: constant_identifier_names

/// Roles defined across the application ecosystem.
enum AppRole {
  super_admin,
  hospital_manager,
  doctor,
  patient,
  scanner_device,
  unverified // Default fallback for newly registered unapproved accounts
}

/// A comprehensive list of restricted actions throughout the app.
enum AppPermission {
  viewDashboard,
  viewMedicalRecord,
  createMedicalRecord,
  updateMedicalRecord,
  viewAppointment,
  createAppointment,
  updateAppointment,
  cancelAppointment,
  approveDoctor,         // KYC Specific
  viewKYCApplications,   // KYC Specific
  submitKYCApplication,  // KYC Specific
}

/// Data class holding current user's security token and parsed custom claims.
class AuthUser {
  final String uid;
  final AppRole role;
  final String? tenantId; // Represents hospital_id for multitenancy
  final String status;    // 'pending' or 'active'

  const AuthUser({
    required this.uid,
    required this.role,
    this.tenantId,
    this.status = 'active', 
  });

  /// Factory constructor to parse Firebase Custom Claims into our domain object.
  factory AuthUser.fromClaims(Map<String, dynamic> claims, String defaultUid) {
    return AuthUser(
      uid: claims['uid'] ?? defaultUid,
      role: AppRole.values.firstWhere(
        (e) => e.name == (claims['role'] ?? 'unverified'), 
        orElse: () => AppRole.unverified,
      ),
      tenantId: claims['tenant_id'],
      status: claims['status'] ?? 'pending', // If no status claim exists, assume pending
    );
  }
}

/// Handles operations related to the Self-service Onboarding and KYC flow.
abstract class KYCRepository {
  /// Submits an application payload to the `doctor_applications` collection.
  Future<void> submitApplication(Map<String, dynamic> data);

  /// Retrieves a list of pending applications targeting a specific tenant.
  Future<List<dynamic>> getPendingApplications(String tenantId);

  /// Approves a doctor. This typically triggers a backend Cloud Function 
  /// which updates Custom Claims and sets the document status to 'approved'.
  Future<void> approveDoctor(String doctorUid, String targetTenantId);
}

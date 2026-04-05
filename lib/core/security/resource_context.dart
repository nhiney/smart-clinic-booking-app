/// Holds attributes for dynamic ABAC (Attribute-Based Access Control) checks.
/// Depending on the action (e.g. updating a medical record vs viewing an appointment),
/// different attributes will be required to validate permissions.
class ResourceContext {
  final String? resourceOwnerId;  // E.g., the patient the record belongs to
  final String? doctorId;         // E.g., the doctor assigned to the record/appointment
  final String? resourceTenantId; // E.g., the hospital the record was created at

  const ResourceContext({
    this.resourceOwnerId,
    this.doctorId,
    this.resourceTenantId,
  });
}

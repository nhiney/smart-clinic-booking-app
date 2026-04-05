import 'package:cloud_functions/cloud_functions.dart';

class ApproveDoctorUseCase {
  final FirebaseFunctions _functions;

  ApproveDoctorUseCase({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> execute({
    required String targetDoctorUid,
    required String tenantId,
  }) async {
    // Admins trigger the backend callable securely rather than writing directly to the database.
    final HttpsCallable callable = _functions.httpsCallable('approveDoctorApplication');
    
    await callable.call({
      'targetUid': targetDoctorUid,
      'tenantId': tenantId,
    });
  }
}

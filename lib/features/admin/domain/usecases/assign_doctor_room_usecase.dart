import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';

@injectable
class AssignDoctorRoomUseCase {
  final FirebaseFunctions _functions;

  AssignDoctorRoomUseCase({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> execute({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
    required String roomId,
  }) async {
    final HttpsCallable callable = _functions.httpsCallable('assignDoctorToRoom');
    await callable.call({
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'departmentId': departmentId,
      'roomId': roomId,
    });
  }
}
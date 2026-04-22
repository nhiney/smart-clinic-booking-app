import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/data/datasources/qr_checkin_remote_datasource.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/data/repositories/qr_checkin_repository_impl.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/repositories/qr_checkin_repository.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/domain/usecases/process_checkin_usecase.dart';
import 'qr_checkin_state.dart';

// 1. Providers cho Data & Domain Layer
final qrFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final qrCheckInDataSourceProvider = Provider<IQRCheckInRemoteDataSource>((ref) {
  return QRCheckInRemoteDataSourceImpl(ref.watch(qrFirestoreProvider));
});

final qrCheckInRepositoryProvider = Provider<IQRCheckInRepository>((ref) {
  return QRCheckInRepositoryImpl(ref.watch(qrCheckInDataSourceProvider));
});

final processCheckInUseCaseProvider = Provider((ref) {
  return ProcessCheckInUseCase(ref.watch(qrCheckInRepositoryProvider));
});

// 2. Controller (StateNotifier)
class QRCheckInController extends StateNotifier<QRCheckInState> {
  final ProcessCheckInUseCase _processCheckInUseCase;

  QRCheckInController(this._processCheckInUseCase) : super(const QRCheckInIdle());

  Future<void> onQRCodeScanned(String bookingId) async {
    if (state is QRCheckInProcessing) return;

    state = const QRCheckInProcessing();
    
    try {
      final result = await _processCheckInUseCase(bookingId);
      state = QRCheckInSuccess(result);
    } catch (e) {
      state = QRCheckInFailure(e.toString());
    }
  }

  void reset() {
    state = const QRCheckInIdle();
  }
}

final qrCheckInControllerProvider = 
    StateNotifierProvider<QRCheckInController, QRCheckInState>((ref) {
  return QRCheckInController(ref.watch(processCheckInUseCaseProvider));
});

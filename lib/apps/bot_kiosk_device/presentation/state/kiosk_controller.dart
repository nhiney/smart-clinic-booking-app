import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/data/datasources/kiosk_remote_datasource.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/data/repositories/kiosk_repository_impl.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/repositories/kiosk_repository.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/usecases/reserve_slot_usecase.dart';
import 'kiosk_state.dart';

// 1. Providers cho Data & Domain
final kioskFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final kioskRemoteDataSourceProvider = Provider<IKioskRemoteDataSource>((ref) {
  return KioskRemoteDataSourceImpl(ref.watch(kioskFirestoreProvider));
});

final kioskRepositoryProvider = Provider<IKioskRepository>((ref) {
  return KioskRepositoryImpl(ref.watch(kioskRemoteDataSourceProvider));
});

final reserveSlotUseCaseProvider = Provider((ref) {
  return ReserveSlotUseCase(ref.watch(kioskRepositoryProvider));
});

// 2. Controller
class KioskController extends StateNotifier<KioskState> {
  final ReserveSlotUseCase _reserveSlotUseCase;
  final IKioskRepository _repository;

  KioskController(this._reserveSlotUseCase, this._repository) : super(const KioskIdle());

  Future<void> selectSlot(String slotId) async {
    // Trong thực tế, chúng ta sẽ fetch slot chi tiết
    // Ở đây giả lập trạng thái đã chọn
    state = KioskLoading();
    try {
      // Giả lập lấy danh sách và chọn (sẽ tích hợp vào UI)
      state = KioskIdle(); // Reset để UI handle chọn
    } catch (e) {
      state = KioskError(e.toString());
    }
  }

  Future<void> confirmBooking(String slotId, String patientName, String phone) async {
    state = const KioskLoading();
    try {
      // Trong thực tế sẽ tạo patientId từ phone/name
      final patientId = 'kiosk_patient_${DateTime.now().millisecondsSinceEpoch}';
      await _reserveSlotUseCase(slotId, patientId);
      state = KioskBookingSuccess('BK-${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      state = KioskError('Lỗi đặt khám: $e');
    }
  }

  void reset() {
    state = const KioskIdle();
  }
}

final kioskControllerProvider = StateNotifierProvider<KioskController, KioskState>((ref) {
  return KioskController(
    ref.watch(reserveSlotUseCaseProvider),
    ref.watch(kioskRepositoryProvider),
  );
});

// Provider để lấy danh sách Slot
final availableSlotsProvider = FutureProvider.family<List, String>((ref, doctorId) async {
  final repository = ref.watch(kioskRepositoryProvider);
  return await repository.getAvailableSlots(doctorId, DateTime.now());
});

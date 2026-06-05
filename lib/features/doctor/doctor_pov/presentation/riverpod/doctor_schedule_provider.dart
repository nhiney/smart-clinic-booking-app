import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/doctor_schedule_remote_datasource.dart';
import '../../data/repositories/doctor_schedule_repository_impl.dart';
import '../../domain/entities/doctor_schedule_slot.dart';
import '../../domain/usecases/get_doctor_day_schedule_usecase.dart';
import '../../domain/usecases/update_slot_status_usecase.dart';

final _datasourceProvider =
    Provider((_) => DoctorScheduleRemoteDatasource());

final _repositoryProvider = Provider(
  (ref) => DoctorScheduleRepositoryImpl(ref.read(_datasourceProvider)),
);

final getDoctorDayScheduleProvider = Provider(
  (ref) => GetDoctorDayScheduleUseCase(ref.read(_repositoryProvider)),
);

final updateSlotStatusProvider = Provider(
  (ref) => UpdateSlotStatusUseCase(ref.read(_repositoryProvider)),
);

// ─── State ───────────────────────────────────────────────────────────────────

class DoctorScheduleState {
  final List<DoctorScheduleSlot> slots;
  final bool isLoading;
  final String? error;

  const DoctorScheduleState({
    this.slots = const [],
    this.isLoading = false,
    this.error,
  });

  DoctorScheduleState copyWith({
    List<DoctorScheduleSlot>? slots,
    bool? isLoading,
    String? error,
  }) =>
      DoctorScheduleState(
        slots: slots ?? this.slots,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class DoctorScheduleNotifier extends StateNotifier<DoctorScheduleState> {
  final GetDoctorDayScheduleUseCase _getSchedule;
  final UpdateSlotStatusUseCase _updateStatus;

  DoctorScheduleNotifier(this._getSchedule, this._updateStatus)
      : super(const DoctorScheduleState());

  Future<void> loadForDay(DateTime date) async {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (doctorId.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final slots = await _getSchedule(doctorId, date);
      state = state.copyWith(slots: slots, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(
      String appointmentId, ScheduleSlotStatus newStatus) async {
    try {
      await _updateStatus(appointmentId, newStatus);
      state = state.copyWith(
        slots: state.slots.map((s) {
          return s.id == appointmentId
              ? DoctorScheduleSlot(
                  id: s.id,
                  patientId: s.patientId,
                  patientName: s.patientName,
                  dateTime: s.dateTime,
                  durationMinutes: s.durationMinutes,
                  type: s.type,
                  status: newStatus,
                  note: s.note,
                  isVideo: s.isVideo,
                  isUrgent: s.isUrgent,
                )
              : s;
        }).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final doctorScheduleProvider =
    StateNotifierProvider<DoctorScheduleNotifier, DoctorScheduleState>(
  (ref) => DoctorScheduleNotifier(
    ref.read(getDoctorDayScheduleProvider),
    ref.read(updateSlotStatusProvider),
  ),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/check_in_remote_datasource.dart';
import '../../data/repositories/check_in_repository_impl.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/services/check_in_token_factory.dart';
import '../../domain/usecases/generate_check_in_token_usecase.dart';
import '../../domain/usecases/verify_check_in_usecase.dart';

final _datasourceProvider = Provider((_) => CheckInRemoteDatasource());
final _repositoryProvider = Provider(
  (ref) => CheckInRepositoryImpl(ref.read(_datasourceProvider)),
);
final _generateTokenProvider = Provider(
  (ref) => GenerateCheckInTokenUseCase(ref.read(_repositoryProvider)),
);
final _verifyCheckInProvider = Provider(
  (ref) => VerifyCheckInUseCase(ref.read(_repositoryProvider)),
);

// ─── State ───────────────────────────────────────────────────────────────────

class CheckInState {
  final String qrData;
  final DateTime validFrom;
  final DateTime expiry;
  final bool isLoading;
  final String? error;

  const CheckInState({
    required this.qrData,
    required this.validFrom,
    required this.expiry,
    this.isLoading = false,
    this.error,
  });

  CheckInState copyWith({
    String? qrData,
    DateTime? validFrom,
    DateTime? expiry,
    bool? isLoading,
    String? error,
  }) =>
      CheckInState(
        qrData: qrData ?? this.qrData,
        validFrom: validFrom ?? this.validFrom,
        expiry: expiry ?? this.expiry,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  bool get isWithinWindow {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(expiry);
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CheckInNotifier extends StateNotifier<CheckInState> {
  final GenerateCheckInTokenUseCase? _generateToken;
  final VerifyCheckInUseCase? _verifyCheckIn;

  CheckInNotifier([this._generateToken, this._verifyCheckIn])
      : super(CheckInState(
          qrData: '',
          validFrom: DateTime.now(),
          expiry: DateTime.now(),
        ));

  Future<void> generateQR(
    String userId,
    String appointmentId, {
    DateTime? appointmentTime,
  }) async {
    // Build the QR token and validity window locally and synchronously so the
    // UI can render immediately; this is the source of truth for the window.
    final entity = CheckInTokenFactory.build(
      patientId: userId,
      appointmentId: appointmentId,
      appointmentTime: appointmentTime,
    );
    state = state.copyWith(
      qrData: entity.token,
      validFrom: entity.validFrom,
      expiry: entity.expiresAt,
      isLoading: false,
      error: null,
    );

    // Best-effort: persist the token to the backend so the clinic can verify
    // it. The UI does not block on this.
    final generate = _generateToken;
    if (generate == null) return;
    try {
      await generate(
        patientId: userId,
        appointmentId: appointmentId,
        appointmentTime: appointmentTime,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<CheckInEntity?> verify(String qrPayload) async {
    final verifyCheckIn = _verifyCheckIn;
    if (verifyCheckIn == null) return null;
    try {
      return await verifyCheckIn(qrPayload);
    } catch (_) {
      return null;
    }
  }

  bool isWithinValidityWindow(DateTime scanTime) {
    return !scanTime.isBefore(state.validFrom) &&
        !scanTime.isAfter(state.expiry);
  }
}

final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>(
  (ref) => CheckInNotifier(
    ref.read(_generateTokenProvider),
    ref.read(_verifyCheckInProvider),
  ),
);

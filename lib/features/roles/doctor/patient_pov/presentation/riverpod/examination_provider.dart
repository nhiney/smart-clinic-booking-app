import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/examination_remote_datasource.dart';
import '../../data/repositories/examination_repository_impl.dart';
import '../../domain/entities/examination_result.dart';
import '../../domain/repositories/examination_repository.dart';
import '../../domain/usecases/save_examination_usecase.dart';

final _datasourceProvider = Provider((_) => ExaminationRemoteDatasource());

final _repositoryProvider = Provider<ExaminationRepository>(
  (ref) => ExaminationRepositoryImpl(ref.read(_datasourceProvider)),
);

final saveExaminationProvider = Provider(
  (ref) => SaveExaminationUseCase(ref.read(_repositoryProvider)),
);

class ExaminationState {
  final bool isSaving;
  final bool isSaved;
  final String? error;

  const ExaminationState({
    this.isSaving = false,
    this.isSaved = false,
    this.error,
  });

  ExaminationState copyWith({bool? isSaving, bool? isSaved, String? error}) =>
      ExaminationState(
        isSaving: isSaving ?? this.isSaving,
        isSaved: isSaved ?? this.isSaved,
        error: error,
      );
}

class ExaminationNotifier extends StateNotifier<ExaminationState> {
  final SaveExaminationUseCase _saveExamination;

  ExaminationNotifier(this._saveExamination) : super(const ExaminationState());

  Future<void> save({
    required String appointmentId,
    required String patientId,
    required String patientName,
    required String diagnosis,
    required String prescription,
    required String notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: 'Chưa đăng nhập tài khoản bác sĩ');
      return;
    }

    state = state.copyWith(isSaving: true, error: null, isSaved: false);
    try {
      await _saveExamination(ExaminationResult(
        appointmentId: appointmentId,
        patientId: patientId,
        patientName: patientName,
        doctorId: user.uid,
        doctorName: user.displayName ?? 'Bác sĩ chuyên khoa',
        diagnosis: diagnosis,
        prescription: prescription,
        notes: notes,
      ));
      state = state.copyWith(isSaving: false, isSaved: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final examinationProvider =
    StateNotifierProvider<ExaminationNotifier, ExaminationState>(
  (ref) => ExaminationNotifier(ref.read(saveExaminationProvider)),
);
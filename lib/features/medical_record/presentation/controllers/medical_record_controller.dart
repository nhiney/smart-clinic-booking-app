import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/entities/medical_record_entity.dart';
import 'package:smart_clinic_booking/features/medical_record/domain/repositories/medical_record_repository.dart';
import 'package:smart_clinic_booking/features/medical_record/data/repositories/medical_record_repository_impl.dart';
import '../riverpod/medical_history_provider.dart';

class MedicalRecordState {
  final bool isLoading;
  final List<MedicalRecordEntity> records;
  final String? error;

  MedicalRecordState({
    this.isLoading = false,
    this.records = const [],
    this.error,
  });

  MedicalRecordState copyWith({
    bool? isLoading,
    List<MedicalRecordEntity>? records,
    String? error,
  }) {
    return MedicalRecordState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      error: error,
    );
  }
}

final medicalRecordControllerProvider = StateNotifierProvider<MedicalRecordController, MedicalRecordState>((ref) {
  return MedicalRecordController(repository: ref.watch(medicalRecordRepositoryProvider));
});

class MedicalRecordController extends StateNotifier<MedicalRecordState> {
  final MedicalRecordRepository repository;

  MedicalRecordController({required this.repository}) : super(MedicalRecordState());

  Future<void> fetchRecords(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await repository.getMedicalRecords(userId);
      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

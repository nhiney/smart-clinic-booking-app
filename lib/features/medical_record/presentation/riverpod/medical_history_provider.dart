import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/encounter_fhir.dart';
import '../../domain/usecases/get_medical_history_usecase.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../../data/repositories/medical_record_repository_impl.dart';
import '../../data/datasources/medical_record_local_datasource.dart';
import '../../data/datasources/medical_record_remote_datasource.dart';
import '../../../../core/database/sqlite_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final medicalRecordRemoteDataSourceProvider = Provider<MedicalRecordRemoteDataSource>((ref) {
  return MedicalRecordRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final medicalRecordLocalDataSourceProvider = Provider<MedicalRecordLocalDataSource>((ref) {
  return MedicalRecordLocalDataSourceImpl(SQLiteHelper.instance);
});

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) {
  return MedicalRecordRepositoryImpl(
    remoteDataSource: ref.watch(medicalRecordRemoteDataSourceProvider),
    localDataSource: ref.watch(medicalRecordLocalDataSourceProvider),
  );
});

final getMedicalHistoryUseCaseProvider = Provider<GetMedicalHistoryUseCase>((ref) {
  return GetMedicalHistoryUseCase(ref.watch(medicalRecordRepositoryProvider));
});

final medicalHistoryProvider = 
    AsyncNotifierProviderFamily<MedicalHistoryNotifier, List<EncounterFhir>, String>(
  MedicalHistoryNotifier.new,
);

class MedicalHistoryNotifier extends FamilyAsyncNotifier<List<EncounterFhir>, String> {
  @override
  Future<List<EncounterFhir>> build(String arg) async {
    final useCase = ref.watch(getMedicalHistoryUseCaseProvider);
    final result = await useCase.execute(arg);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (encounters) => encounters,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

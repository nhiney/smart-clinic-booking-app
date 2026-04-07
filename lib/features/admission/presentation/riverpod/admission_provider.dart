import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/admission_entity.dart';
import '../../domain/repositories/admission_repository.dart';
import '../../data/repositories/admission_repository_impl.dart';
import '../../data/datasources/admission_remote_datasource.dart';

final admissionRemoteDataSourceProvider = Provider<AdmissionRemoteDataSource>((ref) {
  return AdmissionRemoteDataSource();
});

final admissionRepositoryProvider = Provider<AdmissionRepository>((ref) {
  return AdmissionRepositoryImpl(ref.watch(admissionRemoteDataSourceProvider));
});

final admissionListProvider = 
    AsyncNotifierProviderFamily<AdmissionListNotifier, List<AdmissionEntity>, String>(
  AdmissionListNotifier.new,
);

class AdmissionListNotifier extends FamilyAsyncNotifier<List<AdmissionEntity>, String> {
  @override
  Future<List<AdmissionEntity>> build(String arg) async {
    final repo = ref.watch(admissionRepositoryProvider);
    final result = await repo.getAdmissionsByPatient(arg);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (admissions) => admissions,
    );
  }

  Future<void> requestAdmission({
    required String patientId,
    required String reason,
  }) async {
    final repo = ref.watch(admissionRepositoryProvider);
    final admission = AdmissionEntity(
      id: '',
      patientId: patientId,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    
    final result = await repo.requestAdmission(admission);
    result.fold(
      (failure) => null, // Handle error in UI
      (_) => ref.invalidateSelf(), // Refresh list after successful request
    );
  }
}

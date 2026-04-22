import 'dart:io';
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

  Future<String?> requestAdmission({
    required String patientId,
    required String reason,
    String? hospitalId,
    String? doctorId,
    String? contactPhone,
    String? emergencyContact,
    String? emergencyPhone,
    String? insuranceNumber,
    String? priority,
    DateTime? admissionDate,
  }) async {
    final repo = ref.watch(admissionRepositoryProvider);
    final admission = AdmissionEntity(
      id: '',
      patientId: patientId,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now(),
      hospitalId: hospitalId,
      doctorId: doctorId,
      contactPhone: contactPhone,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      insuranceNumber: insuranceNumber,
      priority: priority ?? 'normal',
      admissionDate: admissionDate,
    );

    final result = await repo.requestAdmission(admission);
    return result.fold(
      (failure) => null,
      (id) {
        ref.invalidateSelf();
        return id;
      },
    );
  }

  Future<bool> uploadDocument(String admissionId, File file, String fileName) async {
    final repo = ref.watch(admissionRepositoryProvider);
    final result = await repo.uploadDocument(admissionId, arg, file, fileName);
    return result.fold((f) => false, (_) {
      ref.invalidateSelf();
      return true;
    });
  }
}

final admissionStreamProvider = StreamProvider.family<List<AdmissionEntity>, String>((ref, patientId) {
  final repo = ref.watch(admissionRepositoryProvider);
  return repo.watchAdmissionsByPatient(patientId);
});

final singleAdmissionStreamProvider = StreamProvider.family<AdmissionEntity?, String>((ref, admissionId) {
  final repo = ref.watch(admissionRepositoryProvider);
  return repo.watchAdmission(admissionId);
});

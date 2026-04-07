import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/app_config_service.dart';

// Manual imports for the features lacking @lazySingleton annotations
import '../../features/appointment/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointment/data/repositories/appointment_repository_impl.dart';
import '../../features/appointment/domain/repositories/appointment_repository.dart';
import '../../features/appointment/domain/usecases/get_appointments_usecase.dart';
import '../../features/appointment/domain/usecases/create_appointment_usecase.dart';
import '../../features/appointment/domain/usecases/cancel_appointment_usecase.dart';

import '../../features/medical_record/data/datasources/medical_record_remote_datasource.dart';
import '../../features/medical_record/data/datasources/medical_record_local_datasource.dart';
import '../../features/medical_record/data/repositories/medical_record_repository_impl.dart';
import '../../core/database/sqlite_helper.dart';
import '../../features/medical_record/domain/repositories/medical_record_repository.dart';

import '../../features/medication/data/datasources/medication_remote_datasource.dart';
import '../../features/medication/data/repositories/medication_repository_impl.dart';
import '../../features/medication/domain/repositories/medication_repository.dart';
import '../../features/medication/domain/usecases/get_medications_usecase.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

import '../../features/maps/data/repositories/maps_repository_impl.dart';
import '../../features/maps/domain/repositories/maps_repository.dart';

import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';

import '../../features/admission/data/datasources/admission_remote_datasource.dart';
import '../../features/admission/data/repositories/admission_repository_impl.dart';
import '../../features/admission/domain/repositories/admission_repository.dart';
import '../../core/services/notification_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  // Registers newly added modules that haven't been picked up by build_runner.
  // Replace these with @lazySingleton annotations in the future if preferred.

  // App Config Service (Dynamic Settings)
  getIt.registerLazySingleton(() => AppConfigService());

  // Appointment
  getIt.registerLazySingleton(() => AppointmentRemoteDatasource());
  getIt.registerLazySingleton<AppointmentRepository>(() => AppointmentRepositoryImpl(getIt<AppointmentRemoteDatasource>()));
  getIt.registerLazySingleton(() => GetAppointmentsUseCase(getIt<AppointmentRepository>()));
  getIt.registerLazySingleton(() => CreateAppointmentUseCase(getIt<AppointmentRepository>()));
  getIt.registerLazySingleton(() => CancelAppointmentUseCase(getIt<AppointmentRepository>()));

  // Medical Record
  getIt.registerLazySingleton(() => SQLiteHelper.instance);
  getIt.registerLazySingleton<MedicalRecordRemoteDataSource>(() => MedicalRecordRemoteDataSourceImpl(FirebaseFirestore.instance));
  getIt.registerLazySingleton<MedicalRecordLocalDataSource>(() => MedicalRecordLocalDataSourceImpl(getIt<SQLiteHelper>()));
  getIt.registerLazySingleton<MedicalRecordRepository>(() => MedicalRecordRepositoryImpl(
        remoteDataSource: getIt<MedicalRecordRemoteDataSource>(),
        localDataSource: getIt<MedicalRecordLocalDataSource>(),
      ));

  // Medication
  getIt.registerLazySingleton(() => MedicationRemoteDatasource());
  getIt.registerLazySingleton<MedicationRepository>(() => MedicationRepositoryImpl(getIt<MedicationRemoteDatasource>()));
  getIt.registerLazySingleton(() => GetMedicationsUseCase(getIt<MedicationRepository>()));

  // Profile
  getIt.registerLazySingleton(() => ProfileRemoteDatasource());
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(getIt<ProfileRemoteDatasource>()));

  // Maps
  getIt.registerLazySingleton<MapsRepository>(() => MapsRepositoryImpl());

  // Notification
  getIt.registerLazySingleton(() => NotificationRemoteDatasource());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt<NotificationRemoteDatasource>()));
  getIt.registerLazySingleton(() => SmartNotificationService());

  // Admission
  getIt.registerLazySingleton(() => AdmissionRemoteDataSource());
  getIt.registerLazySingleton<AdmissionRepository>(() => AdmissionRepositoryImpl(getIt<AdmissionRemoteDataSource>()));
}

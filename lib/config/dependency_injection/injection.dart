import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';
import '../../core/services/app_config_service.dart';

// Manual imports for the features lacking @lazySingleton annotations
import '../../features/appointment/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointment/data/repositories/appointment_repository_impl.dart';
import '../../features/appointment/domain/repositories/appointment_repository.dart';
import '../../features/appointment/domain/usecases/get_appointments_usecase.dart';

import '../../features/medical_record/data/datasources/medical_record_remote_datasource.dart';
import '../../features/medical_record/data/repositories/medical_record_repository_impl.dart';
import '../../features/medical_record/domain/repositories/medical_record_repository.dart';

import '../../features/medication/data/datasources/medication_remote_datasource.dart';
import '../../features/medication/data/repositories/medication_repository_impl.dart';
import '../../features/medication/domain/repositories/medication_repository.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

import '../../features/maps/data/datasources/maps_remote_datasource.dart';
import '../../features/maps/data/repositories/maps_repository_impl.dart';
import '../../features/maps/domain/repositories/maps_repository.dart';

import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';

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

  // Medical Record
  getIt.registerLazySingleton(() => MedicalRecordRemoteDatasource());
  getIt.registerLazySingleton<MedicalRecordRepository>(() => MedicalRecordRepositoryImpl(getIt<MedicalRecordRemoteDatasource>()));

  // Medication
  getIt.registerLazySingleton(() => MedicationRemoteDatasource());
  getIt.registerLazySingleton<MedicationRepository>(() => MedicationRepositoryImpl(getIt<MedicationRemoteDatasource>()));

  // Profile
  getIt.registerLazySingleton(() => ProfileRemoteDatasource());
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(getIt<ProfileRemoteDatasource>()));

  // Maps
  getIt.registerLazySingleton(() => MapsRemoteDatasource());
  getIt.registerLazySingleton<MapsRepository>(() => MapsRepositoryImpl(getIt<MapsRemoteDatasource>()));

  // Notification
  getIt.registerLazySingleton(() => NotificationRemoteDatasource());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt<NotificationRemoteDatasource>()));
}

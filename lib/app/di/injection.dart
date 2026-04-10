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
import '../../features/profile/domain/usecases/get_patient_profile.dart';
import '../../features/profile/domain/usecases/update_patient_profile.dart';

import '../../features/maps/data/repositories/maps_repository_impl.dart';
import '../../features/maps/domain/repositories/maps_repository.dart';

import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';

import '../../features/admission/data/datasources/admission_remote_datasource.dart';
import '../../features/admission/data/repositories/admission_repository_impl.dart';
import '../../features/admission/domain/repositories/admission_repository.dart';
import '../../core/services/notification_service.dart';
import '../../features/admin/domain/repositories/facility_repository.dart';
import '../../features/admin/data/repositories/firestore_facility_repository.dart';
import '../../features/doctor/domain/repositories/doctor_repository.dart';
import '../../features/doctor/domain/repositories/doctor_catalog_repository.dart';
import '../../features/doctor/data/repositories/firestore_doctor_repository.dart';
import '../../features/doctor/data/repositories/doctor_catalog_repository_impl.dart';
import '../../features/doctor/data/datasources/doctor_remote_datasource.dart';
import '../../features/doctor/domain/usecases/get_catalog_doctors_usecase.dart';
import '../../features/doctor/domain/usecases/get_catalog_doctor_detail_usecase.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/check_slot_availability_usecase.dart';
import '../../features/booking/domain/usecases/lock_slot_usecase.dart';
import '../../features/booking/domain/usecases/release_slot_lock_usecase.dart';
import '../../features/booking/domain/usecases/confirm_booking_usecase.dart';
import '../../features/booking/domain/usecases/join_waitlist_usecase.dart';
import '../../features/booking/domain/usecases/reschedule_booking_usecase.dart';
import '../../features/booking/domain/usecases/expire_stale_unpaid_bookings_usecase.dart';
import '../../core/services/file_storage_service.dart';
import '../../core/services/seed_data_service.dart';

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
  getIt.registerLazySingleton(() => GetPatientProfile(getIt<ProfileRepository>()));
  getIt.registerLazySingleton(() => UpdatePatientProfile(getIt<ProfileRepository>()));

  // Maps
  getIt.registerLazySingleton<MapsRepository>(() => MapsRepositoryImpl());

  // Notification
  getIt.registerLazySingleton(() => NotificationRemoteDatasource());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(getIt<NotificationRemoteDatasource>()));
  getIt.registerLazySingleton(() => SmartNotificationService());

  // Admission
  getIt.registerLazySingleton(() => AdmissionRemoteDataSource());
  getIt.registerLazySingleton<AdmissionRepository>(() => AdmissionRepositoryImpl(getIt<AdmissionRemoteDataSource>()));

  // Facility & Admin (Manual fallback to ensure stability)
  if (!getIt.isRegistered<FacilityRepository>()) {
    getIt.registerLazySingleton<FacilityRepository>(() => FirestoreFacilityRepository());
  }
  if (!getIt.isRegistered<DoctorRepository>()) {
    getIt.registerLazySingleton<DoctorRepository>(() => FirestoreDoctorRepository());
  }
  if (!getIt.isRegistered<FileStorageService>()) {
    getIt.registerLazySingleton(() => FileStorageService());
  }
  if (!getIt.isRegistered<SeedDataService>()) {
    getIt.registerLazySingleton(() => SeedDataService());
  }

  // Patient doctor discovery (`doctors` collection)
  if (!getIt.isRegistered<DoctorCatalogRepository>()) {
    getIt.registerLazySingleton<DoctorCatalogRepository>(
      () => DoctorCatalogRepositoryImpl(getIt<DoctorRemoteDatasource>()),
    );
  }
  if (!getIt.isRegistered<GetCatalogDoctorsUseCase>()) {
    getIt.registerLazySingleton(
      () => GetCatalogDoctorsUseCase(getIt<DoctorCatalogRepository>()),
    );
  }
  if (!getIt.isRegistered<GetCatalogDoctorDetailUseCase>()) {
    getIt.registerLazySingleton(
      () => GetCatalogDoctorDetailUseCase(getIt<DoctorCatalogRepository>()),
    );
  }

  // Medical booking (`bookings`, `slots`, `waitlist`)
  if (!getIt.isRegistered<BookingRemoteDatasource>()) {
    getIt.registerLazySingleton(() => BookingRemoteDatasource());
  }
  if (!getIt.isRegistered<BookingRepository>()) {
    getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt<BookingRemoteDatasource>()),
    );
  }
  if (!getIt.isRegistered<CheckSlotAvailabilityUseCase>()) {
    getIt.registerLazySingleton(
      () => CheckSlotAvailabilityUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<LockSlotUseCase>()) {
    getIt.registerLazySingleton(
      () => LockSlotUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<ReleaseSlotLockUseCase>()) {
    getIt.registerLazySingleton(
      () => ReleaseSlotLockUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<ConfirmBookingUseCase>()) {
    getIt.registerLazySingleton(
      () => ConfirmBookingUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<JoinWaitlistUseCase>()) {
    getIt.registerLazySingleton(
      () => JoinWaitlistUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<RescheduleBookingUseCase>()) {
    getIt.registerLazySingleton(
      () => RescheduleBookingUseCase(getIt<BookingRepository>()),
    );
  }
  if (!getIt.isRegistered<ExpireStaleUnpaidBookingsUseCase>()) {
    getIt.registerLazySingleton(
      () => ExpireStaleUnpaidBookingsUseCase(getIt<BookingRepository>()),
    );
  }
}

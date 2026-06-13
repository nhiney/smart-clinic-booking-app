import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/roles/doctor/patient_pov/data/datasources/doctor_remote_datasource.dart';
import '../../features/roles/doctor/patient_pov/data/repositories/doctor_catalog_repository_impl.dart';
import '../../features/roles/doctor/patient_pov/data/repositories/firestore_doctor_repository.dart';
import '../../features/roles/doctor/patient_pov/domain/repositories/doctor_catalog_repository.dart';
import '../../features/roles/doctor/patient_pov/domain/repositories/doctor_repository.dart';
import '../../features/roles/doctor/patient_pov/domain/usecases/get_catalog_doctor_detail_usecase.dart';
import '../../features/roles/doctor/patient_pov/domain/usecases/get_catalog_doctors_usecase.dart';
import './injection.config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_clinic_booking/core/services/app_config_service.dart';

// Manual imports for the features lacking @lazySingleton annotations
import 'package:smart_clinic_booking/features/booking_system/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:smart_clinic_booking/features/booking_system/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:smart_clinic_booking/features/booking_system/appointment/domain/repositories/appointment_repository.dart';
import 'package:smart_clinic_booking/features/booking_system/appointment/domain/usecases/get_appointments_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/appointment/domain/usecases/create_appointment_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/appointment/domain/usecases/cancel_appointment_usecase.dart';

import 'package:smart_clinic_booking/features/clinical/medical_record/data/datasources/medical_record_remote_datasource.dart';
import 'package:smart_clinic_booking/features/clinical/medical_record/data/datasources/medical_record_local_datasource.dart';
import 'package:smart_clinic_booking/features/clinical/medical_record/data/repositories/medical_record_repository_impl.dart';
import 'package:smart_clinic_booking/core/database/sqlite_helper.dart';
import 'package:smart_clinic_booking/features/clinical/medical_record/domain/repositories/medical_record_repository.dart';

import 'package:smart_clinic_booking/features/clinical/medication/data/datasources/medication_remote_datasource.dart';
import 'package:smart_clinic_booking/features/clinical/medication/data/repositories/medication_repository_impl.dart';
import 'package:smart_clinic_booking/features/clinical/medication/domain/repositories/medication_repository.dart';
import 'package:smart_clinic_booking/features/clinical/medication/domain/usecases/get_medications_usecase.dart';

import 'package:smart_clinic_booking/features/identity/profile/data/datasources/profile_remote_datasource.dart';
import 'package:smart_clinic_booking/features/identity/profile/data/repositories/profile_repository_impl.dart';
import 'package:smart_clinic_booking/features/identity/profile/domain/repositories/profile_repository.dart';
import 'package:smart_clinic_booking/features/identity/profile/domain/usecases/get_patient_profile.dart';
import 'package:smart_clinic_booking/features/identity/profile/domain/usecases/update_patient_profile.dart';

import 'package:smart_clinic_booking/features/discovery/maps/data/repositories/maps_repository_impl.dart';
import 'package:smart_clinic_booking/features/discovery/maps/domain/repositories/maps_repository.dart';

import 'package:smart_clinic_booking/features/support_services/notification/data/datasources/notification_remote_datasource.dart';
import 'package:smart_clinic_booking/features/support_services/notification/data/repositories/notification_repository_impl.dart';
import 'package:smart_clinic_booking/features/support_services/notification/domain/repositories/notification_repository.dart';

import 'package:smart_clinic_booking/features/clinical/admission/data/datasources/admission_remote_datasource.dart';
import 'package:smart_clinic_booking/features/clinical/admission/data/repositories/admission_repository_impl.dart';
import 'package:smart_clinic_booking/features/clinical/admission/domain/repositories/admission_repository.dart';
import 'package:smart_clinic_booking/core/services/notification_service.dart';
import 'package:smart_clinic_booking/features/roles/admin/domain/repositories/facility_repository.dart';
import 'package:smart_clinic_booking/features/roles/admin/data/repositories/firestore_facility_repository.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/data/datasources/booking_remote_datasource.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/data/repositories/booking_repository_impl.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/repositories/booking_repository.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/check_slot_availability_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/lock_slot_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/release_slot_lock_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/confirm_booking_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/join_waitlist_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/reschedule_booking_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/booking/domain/usecases/expire_stale_unpaid_bookings_usecase.dart';
import 'package:smart_clinic_booking/core/services/file_storage_service.dart';
import 'package:smart_clinic_booking/core/services/seed_data_service.dart';

import 'package:smart_clinic_booking/features/identity/kyc/data/datasources/kyc_remote_datasource.dart';
import 'package:smart_clinic_booking/features/identity/kyc/data/repositories/kyc_repository_impl.dart';
import 'package:smart_clinic_booking/features/identity/kyc/domain/repositories/kyc_repository.dart';

import 'package:smart_clinic_booking/features/booking_system/checkin/data/datasources/check_in_remote_datasource.dart';
import 'package:smart_clinic_booking/features/booking_system/checkin/data/repositories/check_in_repository_impl.dart';
import 'package:smart_clinic_booking/features/booking_system/checkin/domain/repositories/check_in_repository.dart';
import 'package:smart_clinic_booking/features/booking_system/checkin/domain/usecases/generate_check_in_token_usecase.dart';
import 'package:smart_clinic_booking/features/booking_system/checkin/domain/usecases/verify_check_in_usecase.dart';

import 'package:smart_clinic_booking/features/roles/doctor/doctor_pov/data/datasources/doctor_schedule_remote_datasource.dart';
import 'package:smart_clinic_booking/features/roles/doctor/doctor_pov/data/repositories/doctor_schedule_repository_impl.dart';
import 'package:smart_clinic_booking/features/roles/doctor/doctor_pov/domain/repositories/doctor_schedule_repository.dart';
import 'package:smart_clinic_booking/features/roles/doctor/doctor_pov/domain/usecases/get_doctor_day_schedule_usecase.dart';
import 'package:smart_clinic_booking/features/roles/doctor/doctor_pov/domain/usecases/update_slot_status_usecase.dart';

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
  getIt.registerLazySingleton<MedicalRecordRemoteDataSource>(() => MedicalRecordRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
      ));
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

  // KYC
  if (!getIt.isRegistered<KycRemoteDatasource>()) {
    getIt.registerLazySingleton(() => KycRemoteDatasource());
  }
  if (!getIt.isRegistered<KYCRepository>()) {
    getIt.registerLazySingleton<KYCRepository>(
      () => KycRepositoryImpl(getIt<KycRemoteDatasource>()),
    );
  }

  // CheckIn
  if (!getIt.isRegistered<CheckInRemoteDatasource>()) {
    getIt.registerLazySingleton(() => CheckInRemoteDatasource());
  }
  if (!getIt.isRegistered<CheckInRepository>()) {
    getIt.registerLazySingleton<CheckInRepository>(
      () => CheckInRepositoryImpl(getIt<CheckInRemoteDatasource>()),
    );
  }
  if (!getIt.isRegistered<GenerateCheckInTokenUseCase>()) {
    getIt.registerLazySingleton(
      () => GenerateCheckInTokenUseCase(getIt<CheckInRepository>()),
    );
  }
  if (!getIt.isRegistered<VerifyCheckInUseCase>()) {
    getIt.registerLazySingleton(
      () => VerifyCheckInUseCase(getIt<CheckInRepository>()),
    );
  }

  // Doctor Schedule (doctor_pov)
  if (!getIt.isRegistered<DoctorScheduleRemoteDatasource>()) {
    getIt.registerLazySingleton(() => DoctorScheduleRemoteDatasource());
  }
  if (!getIt.isRegistered<DoctorScheduleRepository>()) {
    getIt.registerLazySingleton<DoctorScheduleRepository>(
      () => DoctorScheduleRepositoryImpl(getIt<DoctorScheduleRemoteDatasource>()),
    );
  }
  if (!getIt.isRegistered<GetDoctorDayScheduleUseCase>()) {
    getIt.registerLazySingleton(
      () => GetDoctorDayScheduleUseCase(getIt<DoctorScheduleRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateSlotStatusUseCase>()) {
    getIt.registerLazySingleton(
      () => UpdateSlotStatusUseCase(getIt<DoctorScheduleRepository>()),
    );
  }
}

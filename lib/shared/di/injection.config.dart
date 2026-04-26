// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:smart_clinic_booking/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i514;
import 'package:smart_clinic_booking/features/auth/data/repositories/auth_repository_impl.dart'
    as _i846;
import 'package:smart_clinic_booking/features/auth/domain/repositories/auth_repository.dart'
    as _i63;
import 'package:smart_clinic_booking/features/auth/domain/usecases/login_usecase.dart'
    as _i497;
import 'package:smart_clinic_booking/features/auth/domain/usecases/register_usecase.dart'
    as _i231;
import 'package:smart_clinic_booking/features/auth/domain/usecases/signin_with_phone_usecase.dart'
    as _i1025;
import 'package:smart_clinic_booking/features/auth/domain/usecases/verify_phone_usecase.dart'
    as _i454;

import '../../features/doctor/patient_pov/data/datasources/doctor_remote_datasource.dart' as _i569;
import '../../features/doctor/patient_pov/data/repositories/doctor_repository_impl.dart' as _i679;
import '../../features/doctor/patient_pov/domain/repositories/doctor_repository.dart' as _i791;
import '../../features/doctor/patient_pov/domain/usecases/get_doctors_usecase.dart' as _i812;


extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i514.AuthRemoteDatasource>(
        () => _i514.AuthRemoteDatasource());
    gh.lazySingleton<_i569.DoctorRemoteDatasource>(
        () => _i569.DoctorRemoteDatasource());
    gh.lazySingleton<_i791.DoctorRepository>(
        () => _i679.DoctorRepositoryImpl(gh<_i569.DoctorRemoteDatasource>()));
    gh.lazySingleton<_i63.AuthRepository>(
        () => _i846.AuthRepositoryImpl(gh<_i514.AuthRemoteDatasource>()));
    gh.lazySingleton<_i1025.SignInWithPhoneUseCase>(
        () => _i1025.SignInWithPhoneUseCase(gh<_i63.AuthRepository>()));
    gh.lazySingleton<_i231.RegisterUseCase>(
        () => _i231.RegisterUseCase(gh<_i63.AuthRepository>()));
    gh.lazySingleton<_i497.LoginWithEmailUseCase>(
        () => _i497.LoginWithEmailUseCase(gh<_i63.AuthRepository>()));
    gh.lazySingleton<_i454.VerifyPhoneUseCase>(
        () => _i454.VerifyPhoneUseCase(gh<_i63.AuthRepository>()));
    gh.factory<_i812.GetDoctorsUseCase>(
        () => _i812.GetDoctorsUseCase(gh<_i791.DoctorRepository>()));
    return this;
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(const SignUpState()) {
    on<ToggleRoleEvent>(_onToggleRole);
    on<ToggleLanguageEvent>(_onToggleLanguage); // Handling language toggle
    on<SubmitPatientRegistration>(_onSubmitPatient);
    on<SubmitDoctorRegistration>(_onSubmitDoctor);
  }

  void _onToggleRole(ToggleRoleEvent event, Emitter<SignUpState> emit) {
    emit(state.copyWith(isDoctor: !state.isDoctor, error: null));
  }

  void _onToggleLanguage(ToggleLanguageEvent event, Emitter<SignUpState> emit) {
    emit(state.copyWith(isEnglish: !state.isEnglish));
  }

  Future<void> _onSubmitPatient(
    SubmitPatientRegistration event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    // Simulate generic B2C API / Auth registration delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      if (event.phoneNumber.isEmpty || event.fullName.isEmpty) {
        throw Exception(state.isEnglish ? "Please fill out all required fields." : "Vui lòng điền đầy đủ các thông tin bắt buộc.");
      }
      
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSubmitDoctor(
    SubmitDoctorRegistration event,
    Emitter<SignUpState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    // Simulate extensive B2B KYC API uploads and processing delay
    await Future.delayed(const Duration(seconds: 3));

    try {
      if (event.email.isEmpty || event.password.isEmpty || event.targetHospitalId.isEmpty) {
        throw Exception(state.isEnglish ? "Missing required KYC fields or credentials." : "Thiếu các thông tin KYC bắt buộc hoặc tài khoản.");
      }

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

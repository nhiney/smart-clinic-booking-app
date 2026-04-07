import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/auth_controller.dart';

import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthController authController;

  SignUpBloc({required this.authController}) : super(const SignUpState()) {
    on<ToggleRoleEvent>(_onToggleRole);
    on<ToggleLanguageEvent>(_onToggleLanguage);
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
    
    try {
      final success = await authController.register(
        name: event.fullName,
        phone: event.phoneNumber,
        password: 'default_password', // In real app, this should come from UI
        role: 'patient',
      );

      if (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        throw Exception(authController.errorMessage ?? "Registration failed");
      }
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

    try {
      final success = await authController.register(
        name: event.fullName,
        phone: '', // Doctors use email/password in this mock
        password: event.password,
        role: 'doctor',
        hospitalId: event.targetHospitalId,
        // In real app, upload files first and get URLs
        idCardUrl: 'mock_id_url',
        medicalCertUrl: 'mock_cert_url',
      );

      if (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        throw Exception(authController.errorMessage ?? "Registration failed");
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

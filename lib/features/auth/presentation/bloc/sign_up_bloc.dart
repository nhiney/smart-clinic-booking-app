import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/auth_controller.dart';

import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthController authController;

  SignUpBloc({required this.authController}) : super(const SignUpState()) {
    on<ToggleRoleEvent>(_onToggleRole);
    on<ToggleLanguageEvent>(_onToggleLanguage);
    on<VerifyPhoneEvent>(_onVerifyPhone);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SubmitPatientRegistration>(_onSubmitPatient);
    on<SubmitDoctorRegistration>(_onSubmitDoctor);
  }

  void _onToggleRole(ToggleRoleEvent event, Emitter<SignUpState> emit) {
    emit(state.copyWith(isDoctor: !state.isDoctor, error: null));
  }

  void _onToggleLanguage(ToggleLanguageEvent event, Emitter<SignUpState> emit) {
    emit(state.copyWith(isEnglish: !state.isEnglish));
  }

  Future<void> _onVerifyPhone(VerifyPhoneEvent event, Emitter<SignUpState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, isCodeSent: false));
    try {
      // 1. Check if registered
      final isRegistered = await authController.checkPhoneRegistered(event.phoneNumber);
      if (isRegistered) {
        emit(state.copyWith(isLoading: false, error: "Số điện thoại này đã được đăng ký."));
        return;
      }

      // 2. Start Verification
      await authController.verifyPhone(
        event.phoneNumber,
        onCodeSent: () {
          emit(state.copyWith(
            isLoading: false,
            isCodeSent: true,
            phoneNumber: event.phoneNumber,
            fullName: event.fullName,
            verificationId: authController.verificationId,
          ));
        },
        onAutoVerified: () {
          // Auto-verification handled by AuthController, but we can emit a success state if needed
          emit(state.copyWith(isLoading: false, isSuccess: true));
        },
        onError: (err) {
          emit(state.copyWith(isLoading: false, error: err));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<SignUpState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final success = await authController.verifyOtp(event.smsCode);
      if (success) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(state.copyWith(isLoading: false, error: authController.errorMessage ?? "Mã OTP không hợp lệ."));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
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
      // For simplicity in this task, we keep the bloc event mapping
      // but doctors in ICare are usually created by admins.
      // If we allow registration, it maps to a pending state.
      final success = await authController.register(
        name: event.fullName,
        phone: '', // Placeholder for now
        email: event.email, // Assume event has email or use name as placeholder
        role: 'doctor',
        tenantId: event.targetHospitalId,
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

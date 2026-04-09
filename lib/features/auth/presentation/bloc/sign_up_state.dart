import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  final bool isDoctor;
  final bool isEnglish;
  final bool isLoading;
  final bool isCodeSent;
  final bool isSuccess;
  final String? phoneNumber;
  final String? fullName;
  final String? verificationId;
  final String? error;

  const SignUpState({
    this.isDoctor = false,
    this.isEnglish = false,
    this.isLoading = false,
    this.isCodeSent = false,
    this.isSuccess = false,
    this.phoneNumber,
    this.fullName,
    this.verificationId,
    this.error,
  });

  SignUpState copyWith({
    bool? isDoctor,
    bool? isEnglish,
    bool? isLoading,
    bool? isCodeSent,
    bool? isSuccess,
    String? phoneNumber,
    String? fullName,
    String? verificationId,
    String? error,
  }) {
    return SignUpState(
      isDoctor: isDoctor ?? this.isDoctor,
      isEnglish: isEnglish ?? this.isEnglish,
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isSuccess: isSuccess ?? this.isSuccess,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      verificationId: verificationId ?? this.verificationId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isDoctor,
        isEnglish,
        isLoading,
        isCodeSent,
        isSuccess,
        phoneNumber,
        fullName,
        verificationId,
        error,
      ];
}

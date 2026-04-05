import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  final bool isDoctor;
  final bool isEnglish; // Track language state
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const SignUpState({
    this.isDoctor = false,
    this.isEnglish = false, // Default: Tiếng Việt
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  SignUpState copyWith({
    bool? isDoctor,
    bool? isEnglish,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return SignUpState(
      isDoctor: isDoctor ?? this.isDoctor,
      isEnglish: isEnglish ?? this.isEnglish,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isDoctor, isEnglish, isLoading, isSuccess, error];
}

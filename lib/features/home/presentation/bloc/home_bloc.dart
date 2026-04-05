import 'package:equatable/equatable.dart';
import '../../domain/entities/health_summary.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import '../../../appointment/domain/entities/appointment_entity.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

// ─── Events ─────────────────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  final String userId;
  const HomeLoadRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class HomeMedicationMarkedTaken extends HomeEvent {
  final String reminderId;
  const HomeMedicationMarkedTaken({required this.reminderId});
  @override
  List<Object?> get props => [reminderId];
}

class HomeRefreshRequested extends HomeEvent {
  final String userId;
  const HomeRefreshRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HealthSummary healthSummary;
  final List<MedicationReminder> medicationReminders;
  final List<HealthArticle> healthNews;
  final List<AppointmentEntity> upcomingAppointments;
  final List<DoctorEntity> recommendedDoctors;

  const HomeLoaded({
    required this.healthSummary,
    required this.medicationReminders,
    required this.healthNews,
    required this.upcomingAppointments,
    required this.recommendedDoctors,
  });

  HomeLoaded copyWith({
    HealthSummary? healthSummary,
    List<MedicationReminder>? medicationReminders,
    List<HealthArticle>? healthNews,
    List<AppointmentEntity>? upcomingAppointments,
    List<DoctorEntity>? recommendedDoctors,
  }) {
    return HomeLoaded(
      healthSummary: healthSummary ?? this.healthSummary,
      medicationReminders: medicationReminders ?? this.medicationReminders,
      healthNews: healthNews ?? this.healthNews,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      recommendedDoctors: recommendedDoctors ?? this.recommendedDoctors,
    );
  }

  @override
  List<Object?> get props => [
        healthSummary,
        medicationReminders,
        healthNews,
        upcomingAppointments,
        recommendedDoctors,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}

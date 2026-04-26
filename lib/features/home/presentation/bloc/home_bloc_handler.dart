import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/health_summary.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';
import '../../domain/usecases/get_health_summary_usecase.dart';
import '../../domain/usecases/get_health_news_usecase.dart';
import '../../domain/usecases/medication_usecases.dart';
import '../../../appointment/domain/usecases/get_appointments_usecase.dart';
import '../../../doctor/patient_pov//domain/usecases/get_doctors_usecase.dart';
import 'home_bloc.dart';

class HomeBlocHandler extends Bloc<HomeEvent, HomeState> {
  final GetHealthSummaryUseCase getHealthSummary;
  final GetMedicationRemindersUseCase getMedicationReminders;
  final MarkMedicationTakenUseCase markMedicationTaken;
  final GetHealthNewsUseCase getHealthNews;
  final GetAppointmentsUseCase getAppointments;
  final GetDoctorsUseCase getDoctors;

  HomeBlocHandler({
    required this.getHealthSummary,
    required this.getMedicationReminders,
    required this.markMedicationTaken,
    required this.getHealthNews,
    required this.getAppointments,
    required this.getDoctors,
  }) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeMedicationMarkedTaken>(_onMedicationMarked);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
      HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _fetchAndEmit(event.userId, emit);
  }

  Future<void> _onRefreshRequested(
      HomeRefreshRequested event, Emitter<HomeState> emit) async {
    await _fetchAndEmit(event.userId, emit);
  }

  Future<void> _fetchAndEmit(String userId, Emitter<HomeState> emit) async {
    try {
      // Fetch from home-specific use cases (Either pattern)
      final healthFuture = getHealthSummary(GetHealthSummaryParams(userId: userId));
      final medFuture = getMedicationReminders(GetMedicationRemindersParams(userId: userId));
      final newsFuture = getHealthNews(const GetHealthNewsParams(limit: 5));

      // Fetch from existing use cases (direct return pattern)
      final apptFuture = getAppointments.repository.getAppointmentsByPatient(userId);
      final docFuture = getDoctors.repository.getDoctors();

      final results = await Future.wait([
        healthFuture,
        medFuture,
        newsFuture,
      ]);
      final appts = await apptFuture;
      final docs = await docFuture;

      final healthResult = results[0] as Either<Failure, HealthSummary>;
      final medResult = results[1] as Either<Failure, List<MedicationReminder>>;
      final newsResult = results[2] as Either<Failure, List<HealthArticle>>;

      if (healthResult.isLeft()) {
        final failure = healthResult.fold((f) => f, (_) => null)!;
        emit(HomeError(message: failure.message));
        return;
      }

      emit(HomeLoaded(
        healthSummary: healthResult.fold((l) => throw l, (r) => r),
        medicationReminders: medResult.fold((l) => [], (r) => r),
        healthNews: newsResult.fold((l) => [], (r) => r),
        upcomingAppointments: appts
            .where((a) => a.dateTime.isAfter(DateTime.now()))
            .take(3)
            .toList(),
        recommendedDoctors: docs.take(5).toList(),
      ));
    } catch (e) {
      emit(HomeError(message: 'Không thể tải dữ liệu: $e'));
    }
  }

  Future<void> _onMedicationMarked(
      HomeMedicationMarkedTaken event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final result = await markMedicationTaken(
        MarkMedicationTakenParams(reminderId: event.reminderId));

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (updated) {
        final updatedList = current.medicationReminders.map((m) {
          return m.id == updated.id ? updated : m;
        }).toList();
        emit(current.copyWith(medicationReminders: updatedList));
      },
    );
  }
}

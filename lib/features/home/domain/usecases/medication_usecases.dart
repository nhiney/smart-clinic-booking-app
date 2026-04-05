import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/medication_reminder.dart';
import '../repositories/home_repository.dart';

class GetMedicationRemindersParams {
  final String userId;
  const GetMedicationRemindersParams({required this.userId});
}

class GetMedicationRemindersUseCase
    implements UseCase<List<MedicationReminder>, GetMedicationRemindersParams> {
  final HomeRepository repository;

  const GetMedicationRemindersUseCase(this.repository);

  @override
  Future<Either<Failure, List<MedicationReminder>>> call(
      GetMedicationRemindersParams params) {
    return repository.getMedicationReminders(params.userId);
  }
}

class MarkMedicationTakenParams {
  final String reminderId;
  const MarkMedicationTakenParams({required this.reminderId});
}

class MarkMedicationTakenUseCase
    implements UseCase<MedicationReminder, MarkMedicationTakenParams> {
  final HomeRepository repository;

  const MarkMedicationTakenUseCase(this.repository);

  @override
  Future<Either<Failure, MedicationReminder>> call(MarkMedicationTakenParams params) {
    return repository.markMedicationTaken(params.reminderId);
  }
}

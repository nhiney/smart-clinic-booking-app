import '../entities/examination_result.dart';

abstract class ExaminationRepository {
  Future<String> saveExamination(ExaminationResult result);
}
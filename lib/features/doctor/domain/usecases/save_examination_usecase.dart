import '../entities/examination_result.dart';
import '../repositories/examination_repository.dart';

class SaveExaminationUseCase {
  final ExaminationRepository _repository;

  SaveExaminationUseCase(this._repository);

  Future<String> call(ExaminationResult result) {
    if (result.diagnosis.trim().isEmpty) {
      throw ArgumentError('Chẩn đoán không được để trống');
    }
    return _repository.saveExamination(result);
  }
}
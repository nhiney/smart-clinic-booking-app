import '../entities/examination_result.dart';
import '../repositories/examination_repository.dart';

class SaveExaminationUseCase {
  final ExaminationRepository _repository;

  SaveExaminationUseCase(this._repository);

  Future<String> call(ExaminationResult result) {
    if (result.appointmentId.trim().isEmpty) {
      throw ArgumentError('Mã lịch hẹn (appointmentId) không được để trống');
    }
    if (result.patientId.trim().isEmpty) {
      throw ArgumentError('Mã bệnh nhân (patientId) không được để trống');
    }
    if (result.diagnosis.trim().isEmpty) {
      throw ArgumentError('Chẩn đoán y khoa không được để trống');
    }
    return _repository.saveExamination(result);
  }
}
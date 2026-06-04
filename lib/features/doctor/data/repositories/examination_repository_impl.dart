import '../../domain/entities/examination_result.dart';
import '../../domain/repositories/examination_repository.dart';
import '../datasources/examination_remote_datasource.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  final ExaminationRemoteDatasource _datasource;

  ExaminationRepositoryImpl(this._datasource);

  @override
  Future<String> saveExamination(ExaminationResult result) =>
      _datasource.saveExamination(result);
}
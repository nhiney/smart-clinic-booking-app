import '../../domain/entities/diagnosis_suggestion.dart';
import '../../domain/entities/medication_suggestion.dart';
import '../datasources/clinical_mock_datasource.dart';

class ClinicalAIService {
  final ClinicalMockDataSource dataSource;

  ClinicalAIService({ClinicalMockDataSource? dataSource})
      : dataSource = dataSource ?? ClinicalMockDataSource.instance;

  Future<List<DiagnosisSuggestion>> generateDiagnosisSuggestion() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return dataSource.getDiagnosisSuggestions();
  }

  Future<List<MedicationSuggestion>> generateMedicationSuggestion() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return dataSource.getMedicationSuggestions();
  }
}

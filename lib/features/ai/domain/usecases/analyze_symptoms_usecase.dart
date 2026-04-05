import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/ai_repository.dart';

class AnalyzeSymptomsUseCase implements UseCase<String, AnalyzeSymptomsParams> {
  final AIRepository repository;

  AnalyzeSymptomsUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(AnalyzeSymptomsParams params) async {
    return await repository.analyzeSymptoms(params.symptoms);
  }
}

class AnalyzeSymptomsParams extends Equatable {
  final String symptoms;

  const AnalyzeSymptomsParams({required this.symptoms});

  @override
  List<Object?> get props => [symptoms];
}

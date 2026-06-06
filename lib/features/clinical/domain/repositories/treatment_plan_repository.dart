import 'dart:io';

import '../entities/treatment_plan.dart';

abstract class TreatmentPlanRepository {
  Future<TreatmentPlan> getTreatmentPlan(String encounterId);
  Future<TreatmentPlan> saveTreatmentPlan(TreatmentPlan plan);
  Future<File> exportTreatmentPlanPdf(TreatmentPlan plan);
}

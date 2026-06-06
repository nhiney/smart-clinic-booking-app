import '../entities/clinical_encounter.dart';

abstract class EncounterRepository {
  Future<ClinicalEncounter> getEncounter(String encounterId);
  Future<ClinicalEncounter> saveDraft(ClinicalEncounter encounter);
  Future<ClinicalEncounter> completeEncounter(ClinicalEncounter encounter);
}

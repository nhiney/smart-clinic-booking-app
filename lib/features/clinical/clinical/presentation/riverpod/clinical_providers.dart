import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/clinical_mock_datasource.dart';
import '../../data/repositories/encounter_repository_impl.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../data/repositories/treatment_plan_repository_impl.dart';
import '../../data/services/clinical_ai_service.dart';
import '../../domain/entities/clinical_encounter.dart';
import '../../domain/entities/clinical_chat_message.dart';
import '../../domain/entities/diagnosis_suggestion.dart';
import '../../domain/entities/medication_plan_item.dart';
import '../../domain/entities/medication_suggestion.dart';
import '../../domain/entities/patient.dart';
import '../../domain/entities/treatment_plan.dart';
import '../../domain/repositories/encounter_repository.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../domain/repositories/treatment_plan_repository.dart';

const Object _draftAttachmentLabelUnset = Object();

final clinicalMockDataSourceProvider = Provider<ClinicalMockDataSource>((ref) {
  return ClinicalMockDataSource.instance;
});

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(ref.watch(clinicalMockDataSourceProvider));
});

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) {
  return EncounterRepositoryImpl(ref.watch(clinicalMockDataSourceProvider));
});

final treatmentPlanRepositoryProvider = Provider<TreatmentPlanRepository>((ref) {
  return TreatmentPlanRepositoryImpl(ref.watch(clinicalMockDataSourceProvider));
});

final clinicalAIServiceProvider = Provider<ClinicalAIService>((ref) {
  return ClinicalAIService(dataSource: ref.watch(clinicalMockDataSourceProvider));
});

final patientProfileProvider =
    AsyncNotifierProviderFamily<PatientProfileNotifier, Patient, String>(
  PatientProfileNotifier.new,
);

class PatientProfileNotifier extends FamilyAsyncNotifier<Patient, String> {
  @override
  Future<Patient> build(String arg) async {
    final repository = ref.watch(patientRepositoryProvider);
    return repository.getPatient(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

class ClinicalEncounterState {
  final bool isLoading;
  final bool isSaving;
  final bool isAutoSaving;
  final int elapsedSeconds;
  final int currentStep;
  final DateTime? lastAutosaveAt;
  final Patient? patient;
  final ClinicalEncounter? encounter;
  final List<ClinicalChatMessage> chatMessages;
  final bool isSendingChat;
  final String? draftAttachmentLabel;
  final List<DiagnosisSuggestion> diagnosisSuggestions;
  final List<MedicationSuggestion> medicationSuggestions;
  final String? error;

  const ClinicalEncounterState({
    this.isLoading = false,
    this.isSaving = false,
    this.isAutoSaving = false,
    this.elapsedSeconds = 0,
    this.currentStep = 0,
    this.lastAutosaveAt,
    this.patient,
    this.encounter,
    this.chatMessages = const [],
    this.isSendingChat = false,
    this.draftAttachmentLabel,
    this.diagnosisSuggestions = const [],
    this.medicationSuggestions = const [],
    this.error,
  });

  ClinicalEncounterState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isAutoSaving,
    int? elapsedSeconds,
    int? currentStep,
    DateTime? lastAutosaveAt,
    Patient? patient,
    ClinicalEncounter? encounter,
    List<ClinicalChatMessage>? chatMessages,
    bool? isSendingChat,
    Object? draftAttachmentLabel = _draftAttachmentLabelUnset,
    List<DiagnosisSuggestion>? diagnosisSuggestions,
    List<MedicationSuggestion>? medicationSuggestions,
    String? error,
  }) {
    return ClinicalEncounterState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentStep: currentStep ?? this.currentStep,
      lastAutosaveAt: lastAutosaveAt ?? this.lastAutosaveAt,
      patient: patient ?? this.patient,
      encounter: encounter ?? this.encounter,
      chatMessages: chatMessages ?? this.chatMessages,
      isSendingChat: isSendingChat ?? this.isSendingChat,
      draftAttachmentLabel: identical(draftAttachmentLabel, _draftAttachmentLabelUnset)
          ? this.draftAttachmentLabel
          : draftAttachmentLabel as String?,
      diagnosisSuggestions: diagnosisSuggestions ?? this.diagnosisSuggestions,
      medicationSuggestions: medicationSuggestions ?? this.medicationSuggestions,
      error: error,
    );
  }
}

final clinicalEncounterControllerProvider = StateNotifierProvider.autoDispose
    .family<ClinicalEncounterController, ClinicalEncounterState, String>((ref, encounterId) {
  return ClinicalEncounterController(
    encounterId: encounterId,
    patientRepository: ref.watch(patientRepositoryProvider),
    encounterRepository: ref.watch(encounterRepositoryProvider),
    treatmentPlanRepository: ref.watch(treatmentPlanRepositoryProvider),
    aiService: ref.watch(clinicalAIServiceProvider),
  );
});

class ClinicalEncounterController extends StateNotifier<ClinicalEncounterState> {
  final String encounterId;
  final PatientRepository patientRepository;
  final EncounterRepository encounterRepository;
  final TreatmentPlanRepository treatmentPlanRepository;
  final ClinicalAIService aiService;

  Timer? _clockTimer;
  Timer? _autosaveTimer;

  ClinicalEncounterController({
    required this.encounterId,
    required this.patientRepository,
    required this.encounterRepository,
    required this.treatmentPlanRepository,
    required this.aiService,
  }) : super(const ClinicalEncounterState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        patientRepository.getPatient(encounterId),
        encounterRepository.getEncounter(encounterId),
      ]);

      final patient = results[0] as Patient;
      final encounter = results[1] as ClinicalEncounter;

      state = state.copyWith(
        isLoading: false,
        patient: patient,
        encounter: encounter,
        chatMessages: _seedChatMessages(patient, encounter),
      );
      _startTimers();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimers() {
    _clockTimer?.cancel();
    _autosaveTimer?.cancel();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.encounter == null) {
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });

    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      saveDraft(silent: true);
    });
  }

  List<ClinicalChatMessage> _seedChatMessages(Patient patient, ClinicalEncounter encounter) {
    return [
      ClinicalChatMessage(
        id: 'chat-${encounter.id}-system-1',
        text: 'Lịch hẹn 10:30 hôm nay • ${encounter.diagnosisBadge}',
        sender: ClinicalChatSender.system,
        timestamp: encounter.startedAt.subtract(const Duration(minutes: 2)),
      ),
      ClinicalChatMessage(
        id: 'chat-${encounter.id}-patient-1',
        text: 'Chào bác sĩ, hôm nay đến tái khám em đang đau ngực trở lại 😥',
        sender: ClinicalChatSender.patient,
        timestamp: encounter.startedAt.subtract(const Duration(minutes: 1)),
      ),
      ClinicalChatMessage(
        id: 'chat-${encounter.id}-patient-2',
        text: '',
        sender: ClinicalChatSender.patient,
        timestamp: encounter.startedAt.subtract(const Duration(minutes: 1)),
        attachmentLabel: 'ECG.jpg',
      ),
      ClinicalChatMessage(
        id: 'chat-${encounter.id}-doctor-1',
        text: 'Chào anh An, tôi đã xem kết quả ECG. Đau ngực kiểu nhói hay tức nặng? Có lan ra cánh tay trái không?',
        sender: ClinicalChatSender.doctor,
        timestamp: encounter.startedAt,
      ),
      ClinicalChatMessage(
        id: 'chat-${encounter.id}-patient-3',
        text: 'Tức nặng ạ, hôm qua sau khi leo cầu thang lên tầng 3 là đau lan ra tay trái. Nghỉ 5 phút mới đỡ.',
        sender: ClinicalChatSender.patient,
        timestamp: encounter.startedAt.add(const Duration(minutes: 1)),
      ),
    ];
  }

  void setDraftAttachment(String? label) {
    state = state.copyWith(draftAttachmentLabel: label);
  }

  void clearDraftAttachment() {
    state = state.copyWith(draftAttachmentLabel: null);
  }

  Future<void> sendChatMessage(String text) async {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    final messageText = text.trim();
    final attachment = state.draftAttachmentLabel;
    if (messageText.isEmpty && attachment == null) {
      return;
    }

    state = state.copyWith(isSendingChat: true, error: null);
    final doctorMessage = ClinicalChatMessage(
      id: 'chat-${encounter.id}-${DateTime.now().microsecondsSinceEpoch}',
      text: messageText,
      sender: ClinicalChatSender.doctor,
      timestamp: DateTime.now(),
      attachmentLabel: attachment,
      isRead: false,
    );
    state = state.copyWith(
      chatMessages: [...state.chatMessages, doctorMessage],
      draftAttachmentLabel: null,
    );

    await Future<void>.delayed(const Duration(milliseconds: 750));
    final reply = _buildPatientReply(messageText, attachment);
    if (reply != null) {
      state = state.copyWith(
        chatMessages: [
          ...state.chatMessages,
          ClinicalChatMessage(
            id: 'chat-${encounter.id}-${DateTime.now().microsecondsSinceEpoch + 1}',
            text: reply,
            sender: ClinicalChatSender.patient,
            timestamp: DateTime.now(),
          ),
        ],
      );
    }

    state = state.copyWith(isSendingChat: false);
  }

  Future<void> sendQuickChat(String preset) async {
    if (preset == 'Xem bệnh án') {
      return;
    }
    await sendChatMessage(preset);
  }

  String? _buildPatientReply(String doctorMessage, String? attachmentLabel) {
    final lower = doctorMessage.toLowerCase();
    if (attachmentLabel != null) {
      return 'Em đã gửi ${attachmentLabel.toLowerCase()}. Bác sĩ xem giúp em với ạ.';
    }
    if (lower.contains('uống thuốc')) {
      return 'Dạ em sẽ uống đúng giờ ạ.';
    }
    if (lower.contains('đau') || lower.contains('ngực')) {
      return 'Dạ đau tức nặng, khoảng 6/10 và còn hơi khó thở.';
    }
    if (lower.contains('phòng khám') || lower.contains('phong kham')) {
      return 'Dạ em vào ngay ạ.';
    }
    return 'Dạ, em hiểu rồi ạ.';
  }

  Future<void> saveDraft({bool silent = false}) async {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }

    if (!silent) {
      state = state.copyWith(isSaving: true, error: null);
    } else {
      state = state.copyWith(isAutoSaving: true, error: null);
    }

    try {
      final saved = await encounterRepository.saveDraft(encounter);
      final plan = _buildTreatmentPlan(saved);
      await treatmentPlanRepository.saveTreatmentPlan(plan);
      state = state.copyWith(
        isSaving: false,
        isAutoSaving: false,
        encounter: saved,
        lastAutosaveAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isAutoSaving: false,
        error: e.toString(),
      );
    }
  }

  Future<void> completeEncounter() async {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }

    state = state.copyWith(isSaving: true, error: null);
    try {
      final completed = await encounterRepository.completeEncounter(encounter);
      final plan = _buildTreatmentPlan(completed);
      await treatmentPlanRepository.saveTreatmentPlan(plan);
      state = state.copyWith(
        isSaving: false,
        encounter: completed,
        currentStep: 3,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step.clamp(0, 3));
  }

  void nextStep() {
    if (state.currentStep < 3) {
      setStep(state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      setStep(state.currentStep - 1);
    }
  }

  void updateSubjective(String value) {
    _updateEncounter((encounter) => encounter.copyWith(subjective: value));
  }

  void updateObjective(String value) {
    _updateEncounter((encounter) => encounter.copyWith(objective: value));
  }

  void updateAssessment(String value) {
    _updateEncounter((encounter) => encounter.copyWith(assessment: value));
  }

  void updateNotes(String value) {
    _updateEncounter((encounter) => encounter.copyWith(notes: value));
  }

  void updateFollowUpDate(DateTime? value) {
    _updateEncounter((encounter) => encounter.copyWith(followUpDate: value));
  }

  void addIcdCode(String code) {
    final encounter = state.encounter;
    if (encounter == null || encounter.icdCodes.contains(code)) {
      return;
    }
    _updateEncounter((current) => current.copyWith(icdCodes: [...current.icdCodes, code]));
  }

  void removeIcdCode(String code) {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    _updateEncounter((current) => current.copyWith(
          icdCodes: current.icdCodes.where((item) => item != code).toList(),
        ));
  }

  Future<void> generateDiagnosisSuggestions() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final result = await aiService.generateDiagnosisSuggestion();
      state = state.copyWith(
        isSaving: false,
        diagnosisSuggestions: result,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> generateMedicationSuggestions() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final result = await aiService.generateMedicationSuggestion();
      state = state.copyWith(
        isSaving: false,
        medicationSuggestions: result,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void addMedicationSuggestion(MedicationSuggestion suggestion) {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    final items = [...encounter.medications];
    items.add(
      MedicationPlanItem(
        name: suggestion.name,
        dosage: suggestion.dosage,
        timesPerDay: suggestion.frequency.contains('1') ? 1 : 2,
        days: suggestion.days,
      ),
    );
    _updateEncounter((current) => current.copyWith(medications: items));
  }

  void addMedicationPlan() {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    _updateEncounter((current) => current.copyWith(
          medications: [
            ...current.medications,
            const MedicationPlanItem(
              name: '',
              dosage: '',
              timesPerDay: 1,
              days: 7,
            ),
          ],
        ));
  }

  void removeMedicationPlan(int index) {
    final encounter = state.encounter;
    if (encounter == null || index < 0 || index >= encounter.medications.length) {
      return;
    }
    final items = [...encounter.medications]..removeAt(index);
    _updateEncounter((current) => current.copyWith(medications: items));
  }

  void updateMedicationPlanField(
    int index, {
    String? name,
    String? dosage,
    int? timesPerDay,
    int? days,
    String? notes,
  }) {
    final encounter = state.encounter;
    if (encounter == null || index < 0 || index >= encounter.medications.length) {
      return;
    }
    final items = [...encounter.medications];
    items[index] = items[index].copyWith(
      name: name,
      dosage: dosage,
      timesPerDay: timesPerDay,
      days: days,
      notes: notes,
    );
    _updateEncounter((current) => current.copyWith(medications: items));
  }

  void toggleLabTest(String test) {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    final tests = [...encounter.labTests];
    if (tests.contains(test)) {
      tests.remove(test);
    } else {
      tests.add(test);
    }
    _updateEncounter((current) => current.copyWith(labTests: tests));
  }

  void toggleImagingTest(String test) {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    final tests = [...encounter.imagingTests];
    if (tests.contains(test)) {
      tests.remove(test);
    } else {
      tests.add(test);
    }
    _updateEncounter((current) => current.copyWith(imagingTests: tests));
  }

  TreatmentPlan _buildTreatmentPlan(ClinicalEncounter encounter) {
    return TreatmentPlan(
      id: 'plan-${encounter.id}',
      encounterId: encounter.id,
      patientId: encounter.patientId,
      patientName: encounter.patientName,
      patientCode: encounter.patientCode,
      patientAge: encounter.age,
      patientGender: encounter.gender,
      diagnosisSummary: encounter.assessment,
      icdCodes: List<String>.from(encounter.icdCodes),
      medications: List<MedicationPlanItem>.from(encounter.medications),
      labTests: List<String>.from(encounter.labTests),
      imagingTests: List<String>.from(encounter.imagingTests),
      followUpDate: encounter.followUpDate,
      notes: encounter.notes,
      exportedPdfPath: null,
      updatedAt: DateTime.now(),
    );
  }

  void _updateEncounter(ClinicalEncounter Function(ClinicalEncounter encounter) update) {
    final encounter = state.encounter;
    if (encounter == null) {
      return;
    }
    state = state.copyWith(
      encounter: update(encounter).copyWith(updatedAt: DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _autosaveTimer?.cancel();
    super.dispose();
  }
}

class TreatmentPlanState {
  final bool isLoading;
  final bool isExporting;
  final TreatmentPlan? plan;
  final List<MedicationSuggestion> medicationSuggestions;
  final String? error;

  const TreatmentPlanState({
    this.isLoading = false,
    this.isExporting = false,
    this.plan,
    this.medicationSuggestions = const [],
    this.error,
  });

  TreatmentPlanState copyWith({
    bool? isLoading,
    bool? isExporting,
    TreatmentPlan? plan,
    List<MedicationSuggestion>? medicationSuggestions,
    String? error,
  }) {
    return TreatmentPlanState(
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      plan: plan ?? this.plan,
      medicationSuggestions: medicationSuggestions ?? this.medicationSuggestions,
      error: error,
    );
  }
}

final treatmentPlanControllerProvider = StateNotifierProvider.autoDispose
    .family<TreatmentPlanController, TreatmentPlanState, String>((ref, encounterId) {
  return TreatmentPlanController(
    encounterId: encounterId,
    treatmentPlanRepository: ref.watch(treatmentPlanRepositoryProvider),
    aiService: ref.watch(clinicalAIServiceProvider),
  );
});

class TreatmentPlanController extends StateNotifier<TreatmentPlanState> {
  final String encounterId;
  final TreatmentPlanRepository treatmentPlanRepository;
  final ClinicalAIService aiService;

  TreatmentPlanController({
    required this.encounterId,
    required this.treatmentPlanRepository,
    required this.aiService,
  }) : super(const TreatmentPlanState()) {
    loadPlan();
  }

  Future<void> loadPlan() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final plan = await treatmentPlanRepository.getTreatmentPlan(encounterId);
      state = state.copyWith(isLoading: false, plan: plan);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleLabTest(String test) {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    final tests = [...plan.labTests];
    if (tests.contains(test)) {
      tests.remove(test);
    } else {
      tests.add(test);
    }
    _savePlan(plan.copyWith(labTests: tests));
  }

  void toggleImagingTest(String test) {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    final tests = [...plan.imagingTests];
    if (tests.contains(test)) {
      tests.remove(test);
    } else {
      tests.add(test);
    }
    _savePlan(plan.copyWith(imagingTests: tests));
  }

  void updateFollowUpDate(DateTime? date) {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    _savePlan(plan.copyWith(followUpDate: date));
  }

  void updateNotes(String notes) {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    _savePlan(plan.copyWith(notes: notes));
  }

  Future<void> generateMedicationSuggestions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final suggestions = await aiService.generateMedicationSuggestion();
      state = state.copyWith(
        isLoading: false,
        medicationSuggestions: suggestions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addMedicationSuggestion(MedicationSuggestion suggestion) async {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    final updatedPlan = plan.copyWith(
      medications: [
        ...plan.medications,
        MedicationPlanItem(
          name: suggestion.name,
          dosage: suggestion.dosage,
          timesPerDay: suggestion.frequency.contains('1') ? 1 : 2,
          days: suggestion.days,
        ),
      ],
    );
    await _savePlan(updatedPlan);
  }

  Future<void> exportPdf() async {
    final plan = state.plan;
    if (plan == null) {
      return;
    }
    state = state.copyWith(isExporting: true, error: null);
    try {
      final file = await treatmentPlanRepository.exportTreatmentPlanPdf(plan);
      final reloaded = await treatmentPlanRepository.getTreatmentPlan(encounterId);
      state = state.copyWith(
        isExporting: false,
        plan: reloaded.copyWith(exportedPdfPath: file.path),
      );
    } catch (e) {
      state = state.copyWith(isExporting: false, error: e.toString());
    }
  }

  Future<void> _savePlan(TreatmentPlan plan) async {
    try {
      final saved = await treatmentPlanRepository.saveTreatmentPlan(plan);
      state = state.copyWith(plan: saved, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

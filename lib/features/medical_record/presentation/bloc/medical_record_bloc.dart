import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_medical_records_usecase.dart';
import '../../domain/usecases/upload_medical_attachment_usecase.dart';
import '../../../../core/usecase/usecase.dart'; // added
import 'package:dartz/dartz.dart'; // added for Unit
import 'medical_record_event.dart';
import 'medical_record_state.dart';

class MedicalRecordBloc extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  final GetMedicalRecordsUseCase _getRecordsUseCase;
  final UploadMedicalAttachmentUseCase _uploadAttachmentUseCase;

  MedicalRecordBloc({
    required GetMedicalRecordsUseCase getRecordsUseCase,
    required UploadMedicalAttachmentUseCase uploadAttachmentUseCase,
  })  : _getRecordsUseCase = getRecordsUseCase,
        _uploadAttachmentUseCase = uploadAttachmentUseCase,
        super(MedicalRecordInitial()) {
    on<FetchRecordsEvent>(_onFetchRecords);
    on<UploadAttachmentEvent>(_onUploadAttachment);
  }

  Future<void> _onFetchRecords(
    FetchRecordsEvent event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(MedicalRecordLoading());

    final result = await _getRecordsUseCase.call(GetMedicalRecordsParams(patientId: event.patientId));

    result.fold(
      (failure) => emit(MedicalRecordError(failure.message)),
      (records) => emit(MedicalRecordsLoaded(records)),
    );
  }

  Future<void> _onUploadAttachment(
    UploadAttachmentEvent event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(AttachmentUploadInProgress());

    final result = await _uploadAttachmentUseCase.call(UploadMedicalAttachmentParams(
      file: event.file,
      recordId: event.recordId,
      patientId: event.patientId,
      fileName: event.fileName,
    ));

    result.fold(
      (failure) => emit(AttachmentUploadFailure(failure.message)),
      (_) {
        emit(const AttachmentUploadSuccess('Success'));
        // Trigger a re-fetch of the records to show the new attachment
        add(FetchRecordsEvent(event.patientId));
      },
    );
  }
}

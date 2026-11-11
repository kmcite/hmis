import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';

class PatientDraftState extends Equatable {
  const PatientDraftState({
    this.selectedId,
    this.loaded,
    this.draft,
    this.saving = false,
    this.saveError,
  });

  final String? selectedId;
  final Patient? loaded;
  final Patient? draft;
  final bool saving;
  final Object? saveError;

  bool get isDirty {
    final d = draft;
    final saved = loaded;
    return d != null && saved != null && d != saved;
  }

  bool get canSave => isDirty && !saving;

  PatientDraftState copyWith({
    String? selectedId,
    bool clearSelectedId = false,
    Patient? loaded,
    bool clearLoaded = false,
    Patient? draft,
    bool clearDraft = false,
    bool? saving,
    Object? saveError,
    bool clearSaveError = false,
  }) => PatientDraftState(
    selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
    loaded: clearLoaded ? null : (loaded ?? this.loaded),
    draft: clearDraft ? null : (draft ?? this.draft),
    saving: saving ?? this.saving,
    saveError: clearSaveError ? null : (saveError ?? this.saveError),
  );

  @override
  List<Object?> get props => [selectedId, loaded, draft, saving, saveError];
}

class PatientDraftCubit extends Cubit<PatientDraftState> {
  PatientDraftCubit(this._repository) : super(const PatientDraftState()) {
    _revisionSub = _repository.revisions.listen((_) {
      final id = state.selectedId;
      if (id != null) unawaited(_load(id));
    });
  }

  final PatientsRepository _repository;
  StreamSubscription<int>? _revisionSub;

  void open(String id) {
    emit(state.copyWith(selectedId: id, clearSaveError: true));
    _load(id);
  }

  void clearSelection() => emit(
    state.copyWith(
      clearSelectedId: true,
      clearLoaded: true,
      clearDraft: true,
    ),
  );

  void editName(String name) =>
      emit(state.copyWith(draft: state.draft?.copyWith(patientName: name)));

  void editAge(String age) {
    final current = state.draft;
    if (current == null) return;
    if (age.isEmpty) {
      emit(state.copyWith(draft: current.copyWith(ageYears: null)));
      return;
    }
    final parsed = int.tryParse(age);
    if (parsed != null) {
      emit(state.copyWith(draft: current.copyWith(ageYears: parsed)));
    }
  }

  void editRemarks(String remarks) =>
      emit(state.copyWith(draft: state.draft?.copyWith(remarks: remarks)));

  void editHistory(String history) =>
      emit(state.copyWith(draft: state.draft?.copyWith(history: history)));

  void editExamination(String examination) => emit(
    state.copyWith(draft: state.draft?.copyWith(examination: examination)),
  );

  void editManagement(String management) => emit(
    state.copyWith(draft: state.draft?.copyWith(management: management)),
  );

  void editCaseType(CaseType caseType) =>
      emit(state.copyWith(draft: state.draft?.copyWith(caseType: caseType)));

  void editGender(bool? isMale) =>
      emit(state.copyWith(draft: state.draft?.copyWith(isMale: isMale)));

  void editDate(DateTime date) => emit(
    state.copyWith(
      draft: state.draft?.copyWith(
        date: DateTime(date.year, date.month, date.day),
      ),
    ),
  );

  Future<void> commit() async {
    if (!state.canSave) return;
    final d = state.draft!;
    emit(state.copyWith(saving: true, clearSaveError: true));
    try {
      await _repository.save(d.normalizedForSave());
    } catch (e) {
      emit(state.copyWith(saveError: e));
    } finally {
      emit(state.copyWith(saving: false));
    }
  }

  void revert() => emit(state.copyWith(draft: state.loaded));

  Future<void> _load(String id) async {
    final patient = await _repository.fetchOne(id);
    emit(
      state.copyWith(
        loaded: patient,
        draft: patient != null && state.draft?.id != patient.id ? patient : state.draft,
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';

class ErMarkDraftState extends Equatable {
  const ErMarkDraftState({
    this.selectedId,
    this.loaded,
    this.draft,
    this.saving = false,
    this.saveError,
  });

  final String? selectedId;
  final Mark? loaded;
  final Mark? draft;
  final bool saving;
  final Object? saveError;

  bool get isDirty {
    final d = draft;
    final saved = loaded;
    return d != null && saved != null && d != saved;
  }

  bool get canSave => isDirty && !saving;

  ErMarkDraftState copyWith({
    String? selectedId,
    bool clearSelectedId = false,
    Mark? loaded,
    bool clearLoaded = false,
    Mark? draft,
    bool clearDraft = false,
    bool? saving,
    Object? saveError,
    bool clearSaveError = false,
  }) => ErMarkDraftState(
    selectedId: clearSelectedId ? null : (selectedId ?? this.selectedId),
    loaded: clearLoaded ? null : (loaded ?? this.loaded),
    draft: clearDraft ? null : (draft ?? this.draft),
    saving: saving ?? this.saving,
    saveError: clearSaveError ? null : (saveError ?? this.saveError),
  );

  @override
  List<Object?> get props => [selectedId, loaded, draft, saving, saveError];
}

class ErMarkDraftCubit extends Cubit<ErMarkDraftState> {
  ErMarkDraftCubit(this._repository) : super(const ErMarkDraftState()) {
    _revisionSub = _repository.revisions.listen((_) {
      final id = state.selectedId;
      if (id != null) unawaited(_load(id));
    });
  }

  final MarksRepository _repository;
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

  void editCaseType(CaseType caseType) =>
      emit(state.copyWith(draft: state.draft?.copyWith(caseType: caseType)));

  void editGender(bool isMale) =>
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
    final mark = await _repository.fetchOne(id);
    emit(
      state.copyWith(
        loaded: mark,
        draft: mark != null && state.draft?.id != mark.id ? mark : state.draft,
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

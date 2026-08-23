import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/router.dart';

final erMarkController = provider((f) => ErMarkDraft(marksRepository(f)));

/// Editing state for a single, already-persisted [Mark]: loads it by id,
/// tracks a local editable draft, and commits/reverts against the server.
class ErMarkDraft {
  ErMarkDraft(this._repository) {
    _watcher = effect(() {
      _repository.revision();
      final id = selectedId();
      if (id == null) {
        loaded.value = null;
        return;
      }
      _load(id);
    });
  }

  final MarksRepository _repository;

  final selectedId = signal<String?>(null, name: 'er_mark.selectedId');

  /// Last value fetched from the server for [selectedId].
  final loaded = signal<Mark?>(null, name: 'er_mark.loaded');

  /// Local editable copy of [loaded]. Null when nothing is selected.
  final draft = signal<Mark?>(null, name: 'er_mark.draft');

  final saving = signal(false, name: 'er_mark.saving');
  final saveError = signal<Object?>(null, name: 'er_mark.saveError');

  late final isDirty = computed(() {
    final d = draft();
    final saved = loaded();
    return d != null && saved != null && d != saved;
  }, name: 'er_mark.isDirty');

  late final canSave = computed(
    () => isDirty() && !saving(),
    name: 'er_mark.canSave',
  );

  void open(String id) => selectedId.value = id;
  void close() => selectedId.value = null;

  // --------------------------------------------------------------- edits

  void editName(String name) =>
      draft.value = draft.peek()?.copyWith(patientName: name);

  /// Empty input clears the age rather than leaving the previous value
  /// stranded; garbage input is ignored so a stray keystroke can't wipe it.
  void editAge(String age) {
    final current = draft.peek();
    if (current == null) return;
    if (age.isEmpty) {
      draft.value = current.copyWith(ageYears: null);
      return;
    }
    final parsed = int.tryParse(age);
    if (parsed != null) draft.value = current.copyWith(ageYears: parsed);
  }

  void editRemarks(String remarks) =>
      draft.value = draft.peek()?.copyWith(remarks: remarks);

  void editShift(DutyShift shift) =>
      draft.value = draft.peek()?.copyWith(shift: shift);

  void editCaseType(CaseType caseType) =>
      draft.value = draft.peek()?.copyWith(caseType: caseType);

  void editGender(bool isMale) =>
      draft.value = draft.peek()?.copyWith(isMale: isMale);

  /// Normalised to 00:00 so it matches stored shift dates.
  void editDate(DateTime date) => draft.value = draft.peek()?.copyWith(
    date: DateTime(date.year, date.month, date.day),
  );

  // --------------------------------------------------------------- commit

  Future<void> commit() async {
    if (!canSave.peek()) return;
    final d = draft.peek()!;
    saving.value = true;
    saveError.value = null;
    try {
      await _repository.save(d); // bumps revision → reload → isDirty falls
    } catch (e) {
      saveError.value = e;
    } finally {
      saving.value = false;
    }
  }

  /// Throws away local edits and reloads from the last server copy.
  void revert() => draft.value = loaded.peek();

  Future<void> _load(String id) async {
    final mark = await _repository.fetchOne(id);
    loaded.value = mark;
    // Reseed the draft only if the server handed back a *different*
    // record — a realtime bump shouldn't wipe whatever is being typed.
    if (mark != null && draft.peek()?.id != mark.id) draft.value = mark;
  }

  late final Dispose _watcher;
  void dispose() => _watcher();
}

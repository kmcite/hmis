import 'package:hmis/controllers/er_mark.dart';
import 'package:hmis/controllers/sheet.dart';
import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/router.dart';

final newMarkController = provider(
  (f) => NewMark(marksRepository(f), sheetController(f), erMarkController(f)),
);

/// Create/delete flow for [Mark]s — separate from [ErMarkDraft], which only
/// edits an already-persisted record.
class NewMark {
  NewMark(this._repository, this._sheet, this._draft);

  final MarksRepository _repository;
  final Sheet _sheet;
  final ErMarkDraft _draft;

  /// Non-null while the create sheet is open.
  final newMark = signal<Mark?>(null, name: 'new_mark.newMark');

  late final isCreating = computed(
    () => newMark() != null,
    name: 'new_mark.isCreating',
  );

  final creating = signal(false, name: 'new_mark.creating');
  final createError = signal<Object?>(null, name: 'new_mark.createError');

  late final canCreate = computed(
    () => isCreating() && !creating(),
    name: 'new_mark.canCreate',
  );

  final deleting = signal<String?>(null, name: 'new_mark.deleting');
  final deleteError = signal<Object?>(null, name: 'new_mark.deleteError');

  /// Opens the form seeded to the currently selected shift date, not
  /// DateTime.now() — the sheet the user is looking at is the one they mean.
  void start({DutyShift shift = DutyShift.morning}) => newMark.value = Mark(
    date: _sheet.selectedDay.peek(),
    shift: shift,
    caseType: CaseType.medical,
    createdAt: DateTime.now(),
  );

  void cancel() => newMark.value = null;

  void setShift(DutyShift shift) =>
      newMark.value = newMark.peek()?.copyWith(shift: shift);

  void setCaseType(CaseType caseType) =>
      newMark.value = newMark.peek()?.copyWith(caseType: caseType);

  void setPatientName(String name) =>
      newMark.value = newMark.peek()?.copyWith(patientName: name);

  /// Empty clears; garbage is ignored. Never coerces to 0 — a zero-year-old
  /// and an unrecorded age are different facts on a register.
  void setAgeYears(String age) {
    final current = newMark.peek();
    if (current == null) return;
    if (age.isEmpty) {
      newMark.value = current.copyWith(ageYears: null);
      return;
    }
    final parsed = int.tryParse(age);
    if (parsed != null) newMark.value = current.copyWith(ageYears: parsed);
  }

  void setRemarks(String remarks) =>
      newMark.value = newMark.peek()?.copyWith(remarks: remarks);

  /// Date is a shift date at 00:00 — normalise so it matches stored rows.
  void setDate(DateTime date) => newMark.value = newMark.peek()?.copyWith(
    date: DateTime(date.year, date.month, date.day),
  );

  Future<void> commitMark() async {
    if (!canCreate.peek()) return;
    final draft = newMark.peek()!;
    creating.value = true;
    createError.value = null;
    try {
      await _repository.add(draft); // add(), not save() — no id yet
      newMark.value = null; // close only on success
    } catch (e) {
      createError.value = e;
    } finally {
      creating.value = false;
    }
  }

  Future<void> deleteMark(Mark mark) async {
    if (deleting.peek() != null) return;
    deleting.value = mark.id;
    deleteError.value = null;
    try {
      await _repository.remove(mark.id);
      if (_draft.selectedId.peek() == mark.id) _draft.close();
    } catch (e) {
      deleteError.value = e;
    } finally {
      deleting.value = null;
    }
  }
}

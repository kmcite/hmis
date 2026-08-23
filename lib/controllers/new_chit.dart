import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/router.dart';

final newChitController = provider((f) => NewChit(marksRepository(f)));

/// Standalone "new ER entry" form — a fresh, unsaved [Mark] that either
/// commits to the repository or is discarded.
class NewChit {
  NewChit(this._repository);

  final MarksRepository _repository;

  final mark = signal<Mark?>(null, name: 'new_chit.mark');

  void init() {
    mark.value = Mark(
      date: DateTime.now(),
      shift: DutyShift.morning,
      caseType: CaseType.medical,
    );
  }

  void onDate(DateTime date) => mark.value = mark.peek()?.copyWith(date: date);
  void onShift(DutyShift shift) =>
      mark.value = mark.peek()?.copyWith(shift: shift);
  void onCaseType(CaseType caseType) =>
      mark.value = mark.peek()?.copyWith(caseType: caseType);
  void onPatientName(String patientName) =>
      mark.value = mark.peek()?.copyWith(patientName: patientName);
  void onAgeInYears(String ageYears) => mark.value = mark.peek()?.copyWith(
    ageYears: int.tryParse(ageYears) ?? 0,
  );
  void onIsMale(bool isMale) =>
      mark.value = mark.peek()?.copyWith(isMale: isMale);
  void onRemarks(String remarks) =>
      mark.value = mark.peek()?.copyWith(remarks: remarks);
  void onCreatedAt(DateTime time) =>
      mark.value = mark.peek()?.copyWith(createdAt: time);

  Future<void> save() async {
    final m = mark.peek();
    if (m == null) return;
    await _repository.add(m);
  }
}

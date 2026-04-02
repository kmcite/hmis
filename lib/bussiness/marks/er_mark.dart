// import 'package:hmis/domain/er_mark.dart';
// import 'package:hmis/bussiness/redux.dart';
// import 'package:redux/redux.dart';

import 'package:hmis/bussiness/marks/marks.dart';
import 'package:hmis/domain/er_mark.dart';

/// MIDDLEWARE ACTIONS
@deprecated
class SaveNewMarkAction extends MarkToCreateAction {
  const SaveNewMarkAction();
}

/// REDUCIBLE ACTIONS
sealed class MarkToCreateAction extends MarksAction {
  const MarkToCreateAction();
}

class InitializeNewErMark extends MarkToCreateAction {}

class ClearNewErMark extends MarkToCreateAction {}

class NewMarkShiftAction extends MarkToCreateAction {
  final DutyShift shift;
  const NewMarkShiftAction(this.shift);
}

class NewMarkCaseTypeAction extends MarkToCreateAction {
  final CaseType caseType;
  const NewMarkCaseTypeAction(this.caseType);
}

class NewMarkPatientNameAction extends MarkToCreateAction {
  final String patientName;
  const NewMarkPatientNameAction(this.patientName);
}

class NewMarkAgeYearsAction extends MarkToCreateAction {
  final int ageYears;
  const NewMarkAgeYearsAction(this.ageYears);
}

class NewMarkRemarksAction extends MarkToCreateAction {
  final String remarks;
  const NewMarkRemarksAction(this.remarks);
}

class NewMarkDateAction extends MarkToCreateAction {
  final DateTime date;
  const NewMarkDateAction(this.date);
}

ErMark? markToCreate(ErMark? state, MarkToCreateAction action) {
  return switch (action) {
    InitializeNewErMark() => ErMark(),
    ClearNewErMark() => null,
    NewMarkShiftAction() => state?..shift = action.shift.index,
    NewMarkCaseTypeAction() => state?..caseType = action.caseType.index,
    NewMarkPatientNameAction() => state?..patientName = action.patientName,
    NewMarkAgeYearsAction() => state?..ageYears = action.ageYears,
    NewMarkRemarksAction() => state?..remarks = action.remarks,
    NewMarkDateAction() => state?..date = action.date,
    _ => state,
  };
}

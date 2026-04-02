import 'package:hmis/bussiness/business.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:redux/redux.dart';

class MarksheetMW extends MiddlewareClass<Business> {
  @override
  call(store, action, next) {
    next(action);
    switch (action) {
      default:
    }
  }
}

class CellCountAction {
  final DateTime date;
  final CaseType caseType;
  final DutyShift shift;

  CellCountAction(this.date, this.caseType, this.shift);
}

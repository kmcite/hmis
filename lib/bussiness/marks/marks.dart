import 'dart:async';

import 'package:hmis/bussiness/business.dart';
import 'package:hmis/bussiness/marks/er_mark.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/domain/services.dart';
import 'package:hmis/utils/crud.dart';
import 'package:redux/redux.dart';

class Marks {
  List<ErMark> all = const [];
  ErMark? _lastCached;
  ErMark? get(int id) {
    _lastCached = all.where((e) => e.id == id).firstOrNull;
    return _lastCached;
  }

  /// entire ER sheet (one paper)
  List<ErMark> dailySheet(DateTime date) {
    final d = _day(date);
    return all.where(
      (mark) {
        return mark.date.millisecondsSinceEpoch == d.millisecondsSinceEpoch;
      },
    ).toList();
  }

  /// exact paper cell count
  int cellCount({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final d = _day(date);
    return all.where(
      (mark) {
        return mark.date.millisecondsSinceEpoch == d.millisecondsSinceEpoch &&
            mark.shift == shift.index &&
            mark.caseType == caseType.index;
      },
    ).length;
  }

  /// full ER table (rows × columns)
  Map<CaseType, Map<DutyShift, int>> dailyTable(DateTime date) {
    final marks = dailySheet(date);

    final table = {
      for (final c in CaseType.values)
        c: {
          for (final s in DutyShift.values) s: 0,
        },
    };

    for (final m in marks) {
      final c = CaseType.values[m.caseType];
      final s = DutyShift.values[m.shift];
      table[c]![s] = table[c]![s]! + 1;
    }

    return table;
  }

  /// list patients in one paper cell
  List<ErMark> cellPatients({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final d = _day(date);
    return all.where((mark) {
      return mark.date.millisecondsSinceEpoch == d.millisecondsSinceEpoch &&
          mark.shift == shift.index &&
          mark.caseType == caseType.index;
    }).toList();
  }

  /// for adding mark from a dialog
  ErMark? markToCreate;

  ///

  ErMark? markToDelete;

  /// normalize date to 00:00
  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// total count for all cells on a specific date
  int totalCountForDate(DateTime date) {
    final d = _day(date);
    return all.where(
      (mark) {
        final markDate = _day(mark.date);
        return markDate.millisecondsSinceEpoch == d.millisecondsSinceEpoch;
      },
    ).length;
  }
}

class MarksReducer extends ReducerClass<Marks> {
  call(Marks state, action) {
    switch (action) {
      case PutAllMarks():
        return state..all = action.erMarks;
      case MarkToCreateAction():
        return state..markToCreate = markToCreate(state.markToCreate, action);
      // case InitializeNewErMark():
      //   return state..markToCreate = ErMark();
      // case ClearNewErMark():
      //   return state..markToCreate = null;
      default:
        return state;
    }
  }
}

class MarksAction {
  const MarksAction();
}

class PutAllMarks extends MarksAction {
  final List<ErMark> erMarks;
  PutAllMarks(this.erMarks);
}

class PutMark extends MarksAction {
  final ErMark erMark;
  PutMark(this.erMark);
}

class DeleteMark extends MarksAction {
  final ErMark erMark;
  DeleteMark(this.erMark);
}

class MarkToDeleteAction extends MarksAction {
  final ErMark? erMark;
  MarkToDeleteAction([this.erMark]);
}

class UpdateMarkToCreate extends MarksAction {
  final ErMark erMark;
  UpdateMarkToCreate(this.erMark);
}

class CreateNewMarkAction extends MarksAction {
  // final DateTime date;
  final DutyShift shift;
  final CaseType caseType;

  CreateNewMarkAction(
    // this.date,
    this.shift,
    this.caseType,
  );
}

class UndoMarkAction extends MarksAction {}

class StartListeningToMarksDB extends MarksAction {
  final List<ErMark> erMarks;
  StartListeningToMarksDB(this.erMarks);
}

class StopListeningToMarksDB extends MarksAction {}

class MarksMW extends MiddlewareClass<Business> {
  StreamSubscription? _marksUpdates;

  MarksMW();

  @override
  void call(store, action, next) {
    // Start listening once
    if (_marksUpdates == null) {
      _marksUpdates = objects
          .box<ErMark>()
          .query()
          .watch(triggerImmediately: true)
          .listen((query) {
            final marks = query.find();
            store.dispatch(PutAllMarks(marks));
          });
    }

    switch (action) {
      case StopListeningToMarksDB():
        _marksUpdates?.cancel();
        break;
      case CreateNewMarkAction():
        final normalizedDate = DateTime(
          store.state.settings.date.year,
          store.state.settings.date.month,
          store.state.settings.date.day,
        );
        final newMark = ErMark()
          ..date = normalizedDate
          ..shift = action.shift.index
          ..caseType = action.caseType.index
          ..createdAt = DateTime.now();
        Put(newMark);
        break;
      case DeleteMark():
        Remove(action.erMark);
        break;
      case PutMark():
        Put(action.erMark);
      default:
    }
    next(action);
  }

  void dispose() {
    _marksUpdates?.cancel();
  }
}

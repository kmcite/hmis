import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/models/er_mark.dart';
import 'package:hmis/utils/store.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:objectbox/objectbox.dart';

class ErMarksState {
  final List<ErMark> all;
  final ErMark? lastCached;
  final bool isLoading;
  const ErMarksState({
    required this.all,
    required this.lastCached,
    this.isLoading = false,
  });
}

/// [depends] on [objectService]
class ErMarksBloc extends Cubit<ErMarksState> {
  final Store store;

  StreamSubscription? _marksUpdates;

  ErMarksBloc(this.store)
    : super(const ErMarksState(all: [], lastCached: null, isLoading: true)) {
    _marksUpdates = store.box<ErMark>().query().watch().listen((query) {
      final all = query.find();
      emit(ErMarksState(all: all, lastCached: null, isLoading: false));
    });
    // Initial load
    Future.microtask(() {
      final all = store.box<ErMark>().getAll();
      emit(ErMarksState(all: all, lastCached: null, isLoading: false));
    });
  }

  /// MUTATIONS API
  void deleteMark(ErMark erMark) {
    store.remove(erMark);
  }

  /// Creates a new [ErMark] attributed to the currently selected **shift date**.
  ///
  /// [ErMark.date] is stored as the shift-date (00:00), derived from
  /// [shiftDateOf] — never from raw calendar date.
  /// [ErMark.createdAt] is the real wall-clock time (unmodified).
  void newErMark(DateTime selectedDate, CaseType caseType, DutyShift shift) {
    // selectedDate is already a shift date (chosen via DateBar which uses shiftDateOf)
    final shiftDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final newErMark = ErMark()
      ..date = shiftDate
      ..shift = shift.index
      ..caseType = caseType.index
      ..createdAt = DateTime.now();

    store.put(newErMark);
  }

  Future<void> close() async {
    await _marksUpdates?.cancel();
    super.close();
  }
}

/// EXTENDED MARKS API
extension MarksNotifierApi on ErMarksState {
  ErMark? get(int id) {
    return all.where((e) => e.id == id).firstOrNull;
  }

  /// Returns marks for the currently selected shift date.
  List<ErMark> casesByDay(DateTime date) {
    return dailySheet(date);
  }

  /// Returns all marks whose stored shift-date matches [date].
  ///
  /// [date] is treated as a shift date (00:00 normalized).
  /// [ErMark.date] was stored as shiftDateOf(createdAt) at creation time.
  List<ErMark> dailySheet(DateTime date) {
    final shiftDate = DateTime(date.year, date.month, date.day);
    return all
        .where(
          (mark) =>
              mark.date.millisecondsSinceEpoch ==
              shiftDate.millisecondsSinceEpoch,
        )
        .toList();
  }

  /// Count for the currently selected shift date × shift × caseType cell.
  int currentCellCount(DateTime selectedDate, CaseType caseType, DutyShift shift) {
    return cellCount(
      date: selectedDate,
      shift: shift,
      caseType: caseType,
    );
  }

  /// Exact paper cell count for a given shift date, shift, and case type.
  int cellCount({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final shiftDate = DateTime(date.year, date.month, date.day);
    return all
        .where(
          (mark) =>
              mark.date.millisecondsSinceEpoch ==
                  shiftDate.millisecondsSinceEpoch &&
              mark.shift == shift.index &&
              mark.caseType == caseType.index,
        )
        .length;
  }

  /// Full ER table (rows × columns) for a given shift date.
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

  /// Lists patients in one paper cell for a given shift date.
  List<ErMark> cellPatients({
    required DateTime date,
    required DutyShift shift,
    required CaseType caseType,
  }) {
    final shiftDate = DateTime(date.year, date.month, date.day);
    return all.where((mark) {
      return mark.date.millisecondsSinceEpoch ==
              shiftDate.millisecondsSinceEpoch &&
          mark.shift == shift.index &&
          mark.caseType == caseType.index;
    }).toList();
  }

  /// Total count for all cells on the given shift date.
  int totalCountForDate(DateTime selectedDate) {
    return dailySheet(selectedDate).length;
  }

  /// Returns all marks grouped by their shift date, newest shift first.
  /// Within each group, marks are sorted by [createdAt] descending.
  Map<DateTime, List<ErMark>> get allGroupedByShiftDate {
    final grouped = <DateTime, List<ErMark>>{};
    for (final mark in all) {
      final key = mark.date; // already stored as shift date at 00:00
      grouped.putIfAbsent(key, () => []).add(mark);
    }
    // Sort each group by createdAt descending
    for (final list in grouped.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}

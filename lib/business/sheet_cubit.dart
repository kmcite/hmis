import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';

typedef Cell = ({DutyShift shift, CaseType caseType});

class SheetState extends Equatable {
  const SheetState({
    required this.dayKey,
    this.selectedCell,
    this.marks = const [],
    this.loading = true,
    this.error,
  });

  final String dayKey;
  final Cell? selectedCell;
  final List<Mark> marks;
  final bool loading;
  final Object? error;

  DateTime get selectedDay => DateTime.parse(dayKey);
  int get total => marks.length;

  Map<CaseType, Map<DutyShift, int>> get table {
    final t = {
      for (final c in CaseType.values)
        c: {for (final s in DutyShift.values) s: 0},
    };
    for (final m in marks) {
      final row = t[m.caseType];
      if (row == null) continue;
      row[m.shift] = (row[m.shift] ?? 0) + 1;
    }
    return t;
  }

  List<Mark> get cellMarks {
    final cell = selectedCell;
    if (cell == null) return const <Mark>[];
    return marks
        .where((m) => m.shift == cell.shift && m.caseType == cell.caseType)
        .toList();
  }

  int get cellCount => cellMarks.length;

  SheetState copyWith({
    String? dayKey,
    Cell? selectedCell,
    bool clearSelectedCell = false,
    List<Mark>? marks,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) => SheetState(
    dayKey: dayKey ?? this.dayKey,
    selectedCell: clearSelectedCell
        ? null
        : (selectedCell ?? this.selectedCell),
    marks: marks ?? this.marks,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [dayKey, selectedCell, marks, loading, error];
}

class SheetCubit extends Cubit<SheetState> {
  SheetCubit(this._repository)
    : super(SheetState(dayKey: HospitalTime.sheetKeyFor(DateTime.now()))) {
    _revisionSub = _repository.revisions.listen((_) {
      unawaited(_refetch());
    });
    unawaited(_refetch());
  }

  final MarksRepository _repository;
  StreamSubscription<int>? _revisionSub;

  void initialize() => unawaited(_refetch());

  void showDay(DateTime date) {
    emit(state.copyWith(dayKey: Mark.ymd(date), clearError: true));
    _refetch();
  }

  void showToday() => showDay(HospitalTime.sheetDateFor(DateTime.now()));

  void shiftDay(int days) =>
      showDay(state.selectedDay.add(Duration(days: days)));

  void selectCell(Cell? cell) =>
      emit(state.copyWith(selectedCell: cell, clearSelectedCell: cell == null));

  void refresh() => _refetch();

  Future<Mark> markCase(CaseType caseType) {
    final wall = DateTime.now();
    return _repository.add(
      Mark(
        date: HospitalTime.sheetDateFor(wall),
        shift: HospitalTime.shiftFor(wall),
        caseType: caseType,
        createdAt: wall,
      ).normalizedForSave(wallFallback: wall),
    );
  }

  Future<void> unmarkCase(Mark mark) => _repository.remove(mark.id);

  Future<void> _refetch() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final marks = await _repository.fetchBySheetDate(state.dayKey);
      emit(state.copyWith(marks: marks, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e, loading: false));
    }
  }

  @override
  Future<void> close() {
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

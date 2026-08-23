import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/router.dart';

final sheetController = provider((f) => Sheet(marksRepository(f)));

typedef Cell = ({DutyShift shift, CaseType caseType});

/// State for the marksheet grid: the currently-browsed day, its marks,
/// and the grid cell the user has drilled into (null = whole sheet).
class Sheet {
  Sheet(this._repository) {
    _watcher = effect(() {
      _repository.revision();
      dayKey();
      _refetch();
    });
  }

  final MarksRepository _repository;

  /// Normalised at the boundary — DateTime equality is microsecond-precise,
  /// so storing a raw DateTime refetches the same day on every tick.
  final dayKey = signal(Mark.ymd(DateTime.now()), name: 'sheet.dayKey');

  late final selectedDay = computed(
    () => DateTime.parse(dayKey()),
    name: 'sheet.selectedDay',
  );

  final selectedCell = signal<Cell?>(null, name: 'sheet.selectedCell');

  final marks = signal<List<Mark>>(const [], name: 'sheet.marks');
  final loading = signal(true, name: 'sheet.loading');
  final error = signal<Object?>(null, name: 'sheet.error');

  late final total = computed(() => marks().length, name: 'sheet.total');

  /// Full ER table (rows × columns) for the selected shift date.
  late final table = computed(() {
    final t = {
      for (final c in CaseType.values)
        c: {for (final s in DutyShift.values) s: 0},
    };
    for (final m in marks()) {
      final row = t[m.caseType];
      if (row == null) continue;
      row[m.shift] = (row[m.shift] ?? 0) + 1;
    }
    return t;
  }, name: 'sheet.table');

  /// Marks in the currently selected cell.
  late final cellMarks = computed(() {
    final cell = selectedCell();
    if (cell == null) return const <Mark>[];
    return marks()
        .where((m) => m.shift == cell.shift && m.caseType == cell.caseType)
        .toList();
  }, name: 'sheet.cellMarks');

  late final cellCount = computed(
    () => cellMarks().length,
    name: 'sheet.cellCount',
  );

  void showDay(DateTime date) => dayKey.value = Mark.ymd(date);
  void showToday() => showDay(DateTime.now());
  void shiftDay(int days) =>
      showDay(selectedDay.peek().add(Duration(days: days)));
  void selectCell(Cell? cell) => selectedCell.value = cell;

  /// Manual pull-to-refresh. Normally unnecessary — realtime bumps the
  /// repository's revision.
  void refresh() => _refetch();

  /// Creates a mark on the currently selected shift date.
  ///
  /// [Mark.date] is the shift date at 00:00; [Mark.createdAt] is real
  /// wall-clock time.
  Future<Mark> markCase(CaseType caseType, DutyShift shift) => _repository.add(
    Mark(
      date: selectedDay.peek(),
      shift: shift,
      caseType: caseType,
      createdAt: DateTime.now(),
    ),
  );

  Future<void> unmarkCase(Mark mark) => _repository.remove(mark.id);

  Future<void> _refetch() async {
    loading.value = true;
    error.value = null;
    try {
      marks.value = await _repository.fetchBySheetDate(dayKey.peek());
    } catch (e) {
      error.value = e;
    } finally {
      loading.value = false;
    }
  }

  late final Dispose _watcher;
  void dispose() => _watcher();
}

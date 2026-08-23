import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/router.dart';

final caseRegisterController = provider((f) => CaseRegister(marksRepository(f)));

const _pageSize = 50;

/// The "All Cases" register view: a date range, grouped-by-day marks for
/// it, and paginated loading through the whole range.
class CaseRegister {
  CaseRegister(this._repository) {
    _watcher = effect(() {
      _repository.revision();
      range();
      _reset();
    });
  }

  final MarksRepository _repository;

  /// One signal, not two — setting from/to separately fires an intermediate
  /// fetch with a torn (sometimes inverted) range.
  final range = signal<DateRange?>(null, name: 'case_register.range');

  final marks = signal<List<Mark>>(const [], name: 'case_register.marks');
  final loadingMore = signal(false, name: 'case_register.loadingMore');
  final exhausted = signal(false, name: 'case_register.exhausted');
  int _page = 1;

  /// Register view over the reporting range, newest shift first.
  late final groupedByDay = computed(() {
    final grouped = <DateTime, List<Mark>>{};
    for (final mark in marks()) {
      grouped.putIfAbsent(mark.date, () => []).add(mark);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date));
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }, name: 'case_register.groupedByDay');

  void setRange(DateRange? r) => range.value = r;

  void _reset() {
    _page = 1;
    marks.value = const [];
    exhausted.value = false;
  }

  Future<void> loadMore() async {
    if (loadingMore.peek() || exhausted.peek()) return;
    loadingMore.value = true;
    try {
      final result = await _repository.fetchPage(
        page: _page,
        perPage: _pageSize,
        range: range.peek(),
      );
      marks.value = [...marks.peek(), ...result.items];
      exhausted.value = result.items.length < _pageSize;
      _page++;
    } finally {
      loadingMore.value = false;
    }
  }

  late final Dispose _watcher;
  void dispose() => _watcher();
}

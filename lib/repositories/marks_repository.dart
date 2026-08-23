import 'package:hmis/models/models.dart';
import 'package:hmis/services/pocketbase.dart';
import 'package:hmis/utils/router.dart';
import 'package:pocketbase/pocketbase.dart';

/// Counts keyed by (shift, caseType) — the paper grid.
typedef SheetTally = Map<DutyShift, Map<CaseType, int>>;

typedef DateRange = ({DateTime from, DateTime to});

typedef Page<T> = ({List<T> items, int total});

final marksRepository = provider(
  (f) => MarksRepository(pocketBaseServiceProvider(f)),
);

class MarksRepository {
  MarksRepository(this._service);
  final PocketBaseService _service;

  RecordService get _collection => _service.pocketbase.collection('marks');

  // ----------------------------------------------------------- invalidation

  /// Every read a consumer cares about should re-run when this changes;
  /// every write bumps it.
  final revision = signal(0, name: 'MarksRepository.revision');
  void _bump() => revision.value++;

  /// Starts the realtime watcher. Safe to call again after a reconnect —
  /// tears down the previous subscription first.
  Future<void> Function()? _unsubscribe;
  Future<void> startWatching() async {
    await _unsubscribe?.call();
    final sub = await _collection.subscribe('*', (_) => _bump());
    _unsubscribe = () async => sub();
  }

  // ------------------------------------------------------------------ reads

  Future<List<Mark>> fetchBySheetDate(String ymd) async {
    final records = await _collection.getFullList(
      batch: 500,
      filter: _service.pocketbase.filter('sheet_date = {:d}', {'d': ymd}),
      sort: 'created',
    );
    return records.map(Mark.fromRecord).toList();
  }

  Future<List<Mark>> fetchByRange(DateRange range) async {
    final records = await _collection.getFullList(
      batch: 500,
      filter: _service.pocketbase.filter(
        'sheet_date >= {:a} && sheet_date <= {:b}',
        {'a': Mark.ymd(range.from), 'b': Mark.ymd(range.to)},
      ),
      sort: 'sheet_date,created',
    );
    return records.map(Mark.fromRecord).toList();
  }

  Future<Page<Mark>> fetchPage({
    required int page,
    required int perPage,
    DateRange? range,
  }) async {
    final filter = range == null
        ? ''
        : _service.pocketbase.filter(
            'sheet_date >= {:a} && sheet_date <= {:b}',
            {'a': Mark.ymd(range.from), 'b': Mark.ymd(range.to)},
          );
    final result = await _collection.getList(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: '-sheet_date,-created',
    );
    return (
      items: result.items.map(Mark.fromRecord).toList(),
      total: result.totalItems,
    );
  }

  Future<Mark?> fetchOne(String id) async {
    return Mark.fromRecord(await _collection.getOne(id));
  }

  // ----------------------------------------------------------------- writes

  Future<Mark> add(Mark mark) async {
    final saved = Mark.fromRecord(
      await _collection.create(body: mark.toBody()),
    );
    _bump();
    return saved;
  }

  Future<Mark> save(Mark mark) async {
    if (!mark.isPersisted) {
      throw StateError('save() needs a persisted record; use add()');
    }
    final saved = Mark.fromRecord(
      await _collection.update(mark.id, body: mark.toBody()),
    );
    _bump();
    return saved;
  }

  Future<void> remove(String id) async {
    await _collection.delete(id);
    _bump();
  }

  // ------------------------------------------------------------- aggregation

  /// Client-side grid tally. A day is a few hundred rows at most, so this
  /// beats one getList(perPage: 1) round trip per cell.
  SheetTally tally(Iterable<Mark> marks) {
    final out = <DutyShift, Map<CaseType, int>>{
      for (final s in DutyShift.values)
        s: {for (final c in CaseType.values) c: 0},
    };
    for (final m in marks) {
      final row = out[m.shift];
      if (row == null) continue; // schema drift shouldn't crash the sheet
      row[m.caseType] = (row[m.caseType] ?? 0) + 1;
    }
    return out;
  }

  int total(SheetTally t) =>
      t.values.expand((row) => row.values).fold(0, (a, b) => a + b);
}

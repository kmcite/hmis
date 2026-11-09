import 'dart:async';

import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/hmis_local_store.dart';
import 'package:hmis/domain/repositories/mark_entity_mapper.dart';
import 'package:hmis/objectbox.g.dart';
import 'package:hmis/services/ids.dart';

typedef SheetTally = Map<DutyShift, Map<CaseType, int>>;
typedef DateRange = ({DateTime from, DateTime to});
typedef Page<T> = ({List<T> items, int total});

class MarksRepository {
  MarksRepository(this._local);

  static const collectionName = 'marks';

  final HmisLocalStore _local;
  final _revisions = StreamController<int>.broadcast();

  int _revision = 0;

  /// Fires when local marks or outbox change (mutations or sync merge).
  Stream<int> get revisions => _revisions.stream;

  Future<int> readRevision() async => _revision;

  void _bump() {
    _revision++;
    _revisions.add(_revision);
  }

  Future<void> notifySyncCompleted() async => _bump();

  void dispose() {
    _revisions.close();
  }

  MarkEntity? _entityByAnyId(String id) {
    final byRemote = _local.marks
        .query(
          MarkEntity_.remoteId
              .equals(id)
              .and(MarkEntity_.isDeleted.equals(false)),
        )
        .build()
        .findFirst();
    if (byRemote != null) return byRemote;
    return _local.marks
        .query(
          MarkEntity_.clientId
              .equals(id)
              .and(MarkEntity_.isDeleted.equals(false)),
        )
        .build()
        .findFirst();
  }

  Future<List<Mark>> fetchBySheetDate(String ymd) async {
    final rows = _local.marks
        .query(
          MarkEntity_.sheetDateYmd
              .equals(ymd)
              .and(MarkEntity_.isDeleted.equals(false)),
        )
        .order(MarkEntity_.createdAtMs)
        .build()
        .find();
    return rows.map((e) => e.toDomain()).toList();
  }

  Future<List<Mark>> fetchByRange(DateRange range) async {
    final from = Mark.ymd(range.from);
    final to = Mark.ymd(range.to);
    final rows = _local.marks
        .query(
          MarkEntity_.sheetDateYmd
              .greaterOrEqual(from)
              .and(MarkEntity_.sheetDateYmd.lessOrEqual(to))
              .and(MarkEntity_.isDeleted.equals(false)),
        )
        .order(MarkEntity_.sheetDateYmd)
        .order(MarkEntity_.createdAtMs)
        .build()
        .find();
    return rows.map((e) => e.toDomain()).toList();
  }

  Future<Page<Mark>> fetchPage({
    required int page,
    required int perPage,
    DateRange? range,
  }) async {
    Condition<MarkEntity> cond = MarkEntity_.isDeleted.equals(false);
    if (range != null) {
      final from = Mark.ymd(range.from);
      final to = Mark.ymd(range.to);
      cond = cond
          .and(MarkEntity_.sheetDateYmd.greaterOrEqual(from))
          .and(MarkEntity_.sheetDateYmd.lessOrEqual(to));
    }

    final all = _local.marks
        .query(cond)
        .order(MarkEntity_.sheetDateYmd, flags: Order.descending)
        .order(MarkEntity_.createdAtMs, flags: Order.descending)
        .build()
        .find();

    final start = (page - 1) * perPage;
    final slice = start >= all.length
        ? <MarkEntity>[]
        : all.skip(start).take(perPage).toList();

    return (
      items: slice.map((e) => e.toDomain()).toList(),
      total: all.length,
    );
  }

  Future<Mark?> fetchOne(String id) async {
    return _entityByAnyId(id)?.toDomain();
  }

  Future<Mark> add(Mark mark) async {
    final clientId = localClientId();
    final ms = nowMs();
    final stored = mark.normalizedForSave();
    final entity = markEntityFromDomain(
      stored,
      clientId: clientId,
      updatedAtMs: ms,
    )..createdAtMs ??= ms;

    _local.marks.put(entity);
    _enqueue(clientId, 'create');
    _bump();
    return entity.toDomain();
  }

  Future<Mark> save(Mark mark) async {
    final entity = _entityByAnyId(mark.id);
    if (entity == null) {
      throw StateError('save() needs a local mark; use add() for new rows');
    }

    final stored = mark.normalizedForSave();
    final updated = markEntityFromDomain(
      stored,
      clientId: entity.clientId,
      remoteId: entity.remoteId,
      updatedAtMs: nowMs(),
    )..id = entity.id;

    _local.marks.put(updated);
    _enqueue(entity.clientId, entity.remoteId == null ? 'create' : 'update');
    _bump();
    return updated.toDomain();
  }

  Future<void> remove(String id) async {
    final entity = _entityByAnyId(id);
    if (entity == null) return;

    entity
      ..isDeleted = true
      ..updatedAtMs = nowMs();
    _local.marks.put(entity);
    _enqueue(entity.clientId, 'delete');
    _bump();
  }

  void _enqueue(String clientId, String operation) {
    final pending = _local.outbox
        .query(
          OutboxEntry_.entityClientId
              .equals(clientId)
              .and(OutboxEntry_.status.lessThan(2)),
        )
        .build()
        .find();

    if (operation == 'delete') {
      for (final e in pending) {
        _local.outbox.remove(e.id);
      }
      _local.outbox.put(
        OutboxEntry(
          entityClientId: clientId,
          operation: 'delete',
          createdAtMs: nowMs(),
        ),
      );
      return;
    }

    if (pending.any((e) => e.operation == 'create')) {
      return;
    }

    if (pending.any((e) => e.operation == 'update')) {
      return;
    }

    _local.outbox.put(
      OutboxEntry(
        entityClientId: clientId,
        operation: operation,
        createdAtMs: nowMs(),
      ),
    );
  }

  SheetTally tally(Iterable<Mark> marks) {
    final out = <DutyShift, Map<CaseType, int>>{
      for (final s in DutyShift.values)
        s: {for (final c in CaseType.values) c: 0},
    };
    for (final m in marks) {
      final row = out[m.shift];
      if (row == null) continue;
      row[m.caseType] = (row[m.caseType] ?? 0) + 1;
    }
    return out;
  }

  int total(SheetTally t) =>
      t.values.expand((row) => row.values).fold(0, (a, b) => a + b);

  Future<int> pendingOutboxCount() async =>
      _local.outbox.query(OutboxEntry_.status.lessThan(2)).build().count();
}

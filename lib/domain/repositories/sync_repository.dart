import 'dart:async';

import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/hmis_local_store.dart';
import 'package:hmis/domain/repositories/mark_entity_mapper.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';
import 'package:hmis/objectbox.g.dart';
import 'package:hmis/services/ids.dart';
import 'package:hmis/services/pocketbase.dart';
import 'package:pocketbase/pocketbase.dart';

/// Outbox-pattern sync: ObjectBox is authoritative; PocketBase is optional replica.
class SyncRepository {
  SyncRepository(this._local, this._repository);

  final HmisLocalStore _local;
  final MarksRepository _repository;

  static const _lastPullKey = 'last_pull_iso';

  bool _busy = false;
  final _busyState = StreamController<bool>.broadcast();

  Stream<bool> get busy => _busyState.stream;

  Future<bool> readBusy() async => _busy;

  Future<int> pendingCount() async =>
      _local.outbox.query(OutboxEntry_.status.lessThan(2)).build().count();

  Future<void> syncIfPossible(PocketBaseService service) async {
    final session = await service.readSession();
    if (await readBusy() || !session.isOpen) return;
    _setBusy(true);
    try {
      await _pushOutbox(session);
      await _pullRemote(session);
      await _repository.notifySyncCompleted();
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    _busyState.add(_busy);
  }

  void dispose() {
    _busyState.close();
  }

  Future<void> _pushOutbox(PocketBaseSession session) async {
    final collection = session.requireClient.collection(
      MarksRepository.collectionName,
    );
    final q = _local.outbox
        .query(OutboxEntry_.status.equals(0))
        .order(OutboxEntry_.createdAtMs)
        .build();
    final entries = q.find();

    for (final entry in entries) {
      entry.status = 1;
      _local.outbox.put(entry);

      try {
        final mark = _local.marks
            .query(MarkEntity_.clientId.equals(entry.entityClientId))
            .build()
            .findFirst();
        if (mark == null) {
          _local.outbox.remove(entry.id);
          continue;
        }

        switch (entry.operation) {
          case 'create':
            if (mark.remoteId != null) {
              _local.outbox.remove(entry.id);
              break;
            }
            final body = _bodyFromEntity(mark);
            final saved = await collection.create(body: body);
            mark.remoteId = saved.id;
            mark.updatedAtMs = nowMs();
            _local.marks.put(mark);
            _local.outbox.remove(entry.id);
          case 'update':
            if (mark.remoteId == null) {
              entry.operation = 'create';
              entry.status = 0;
              _local.outbox.put(entry);
              break;
            }
            await collection.update(
              mark.remoteId!,
              body: _bodyFromEntity(mark),
            );
            _local.outbox.remove(entry.id);
          case 'delete':
            if (mark.remoteId != null) {
              await collection.delete(mark.remoteId!);
            }
            _local.outbox.remove(entry.id);
        }
      } catch (e) {
        entry.status = 2;
        entry.attemptCount++;
        entry.lastError = e.toString();
        _local.outbox.put(entry);
      }
    }
  }

  Future<void> _pullRemote(PocketBaseSession session) async {
    final pb = session.requireClient;
    final collection = pb.collection(MarksRepository.collectionName);
    final lastPull = _local.getMeta(_lastPullKey);

    final filter = lastPull == null || lastPull.isEmpty
        ? ''
        : pb.filter('updated > {:t}', {'t': lastPull});

    final records = await collection.getFullList(
      batch: 500,
      filter: filter,
      sort: 'updated',
    );

    for (final record in records) {
      await _mergeRemote(record);
    }

    if (records.isNotEmpty) {
      final newest = records.last.get<String>('updated');
      _local.setMeta(_lastPullKey, newest);
    } else if (lastPull == null) {
      _local.setMeta(_lastPullKey, DateTime.now().toUtc().toIso8601String());
    }
  }

  Future<void> _mergeRemote(RecordModel record) async {
    final remoteId = record.id;
    final mark =
        _local.marks
            .query(MarkEntity_.remoteId.equals(remoteId))
            .build()
            .findFirst() ??
        _local.marks
            .query(MarkEntity_.clientId.equals(remoteId))
            .build()
            .findFirst();

    if (mark != null && _hasPendingOutbox(mark.clientId)) {
      return;
    }

    final domain = Mark.fromRecord(record);
    if (mark == null) {
      final clientId = localClientId();
      final entity = markEntityFromDomain(
        domain,
        clientId: clientId,
        remoteId: remoteId,
        updatedAtMs: _parseUpdatedMs(record),
      );
      _local.marks.put(entity);
    } else {
      mark
        ..remoteId = remoteId
        ..sheetDateYmd = Mark.ymd(domain.date)
        ..dateMs = Mark.dateOnly(domain.date).millisecondsSinceEpoch
        ..shift = domain.shift.name
        ..caseType = domain.caseType.name
        ..patientName = domain.patientName
        ..ageYears = domain.ageYears
        ..sexCode = domain.isMale == null
            ? -1
            : domain.isMale!
            ? 1
            : 0
        ..remarks = domain.remarks
        ..createdAtMs = domain.createdAt?.millisecondsSinceEpoch
        ..updatedAtMs = _parseUpdatedMs(record)
        ..isDeleted = false;
      _local.marks.put(mark);
    }
  }

  int _parseUpdatedMs(RecordModel record) {
    final raw = record.get<String>('updated');
    return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? nowMs();
  }

  bool _hasPendingOutbox(String clientId) =>
      _local.outbox
          .query(
            OutboxEntry_.entityClientId
                .equals(clientId)
                .and(OutboxEntry_.status.lessThan(2)),
          )
          .build()
          .count() >
      0;

  Map<String, dynamic> _bodyFromEntity(MarkEntity e) => Mark(
    id: e.remoteId ?? e.clientId,
    date: DateTime.fromMillisecondsSinceEpoch(e.dateMs),
    shift: DutyShift.parse(e.shift),
    caseType: CaseType.parse(e.caseType),
    patientName: e.patientName,
    ageYears: e.ageYears,
    isMale: e.sexCode < 0 ? null : e.sexCode == 1,
    remarks: e.remarks,
    createdAt: e.createdAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(e.createdAtMs!),
  ).toBody();
}

import 'dart:async';

import 'package:hmis/domain/models/models.dart';
import 'package:hmis/services/ids.dart';
import 'package:shared_database/shared_database.dart';

typedef SheetTally = Map<DutyShift, Map<CaseType, int>>;
typedef DateRange = ({DateTime from, DateTime to});
typedef Page<T> = ({List<T> items, int total});

/// Patients persisted as JSON documents in the shared on-device database.
///
/// The repository keeps an in-memory copy hydrated from [SharedDatabase.all]
/// and refreshed through [SharedDatabase.watchCollection], so writes from
/// sibling apps surface via [revisions] like local mutations do.
class PatientsRepository {
  PatientsRepository(this._db);

  final SharedDatabase _db;

  static const collectionName = 'patients';

  final _patients = <String, Patient>{};
  final _revisions = StreamController<int>.broadcast();

  Future<void>? _loading;
  StreamSubscription<List<SharedRecord>>? _watchSub;
  int _revision = 0;

  /// Fires when patients change (local mutations or shared-db updates).
  Stream<int> get revisions => _revisions.stream;

  Future<int> readRevision() async => _revision;

  void _bump() {
    _revision++;
    _revisions.add(_revision);
  }

  void dispose() {
    unawaited(_watchSub?.cancel());
    _revisions.close();
  }

  Future<void> _ensureLoaded() =>
      _loading ??= _load().whenComplete(() => _loading = null);

  Future<void> _load() async {
    await _db.ensure(collectionName);
    final records = await _db.all(collectionName);
    _applyRecords(records);
    _watchSub ??= _db
        .watchCollection(collectionName)
        .listen(_onSharedUpdate, onError: (_) {});
  }

  void _onSharedUpdate(List<SharedRecord> records) {
    if (_applyRecords(records)) _bump();
  }

  /// Rebuilds the cache; returns true when the patient set actually changed.
  bool _applyRecords(List<SharedRecord> records) {
    final next = <String, Patient>{
      for (final r in records)
        if (_decode(r) case final patient?) r.id: patient,
    };
    if (_samePatients(_patients, next)) return false;
    _patients
      ..clear()
      ..addAll(next);
    return true;
  }

  static bool _samePatients(Map<String, Patient> a, Map<String, Patient> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  static Patient? _decode(SharedRecord r) {
    try {
      return Patient.fromData(r.id, r.data);
    } catch (_) {
      return null;
    }
  }

  List<Patient> get _sorted => _patients.values.toList()
    ..sort(
      (a, b) => (a.createdAt ?? a.date).compareTo(b.createdAt ?? b.date),
    );

  Future<List<Patient>> fetchBySheetDate(String ymd) async {
    await _ensureLoaded();
    return _sorted
        .where((m) => Patient.ymd(m.date) == ymd)
        .toList();
  }

  Future<List<Patient>> fetchByRange(DateRange range) async {
    await _ensureLoaded();
    final from = Patient.ymd(range.from);
    final to = Patient.ymd(range.to);
    final rows = _patients.values.where((m) {
      final key = Patient.ymd(m.date);
      return key.compareTo(from) >= 0 && key.compareTo(to) <= 0;
    }).toList()
      ..sort((a, b) {
        final byDay = Patient.ymd(a.date).compareTo(Patient.ymd(b.date));
        if (byDay != 0) return byDay;
        return (a.createdAt ?? a.date).compareTo(b.createdAt ?? b.date);
      });
    return rows;
  }

  Future<Page<Patient>> fetchPage({
    required int page,
    required int perPage,
    DateRange? range,
  }) async {
    await _ensureLoaded();
    final all = _patients.values.toList()
      ..sort((a, b) {
        final byDay = Patient.ymd(b.date).compareTo(Patient.ymd(a.date));
        if (byDay != 0) return byDay;
        return (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date);
      });

    final List<Patient> filtered;
    if (range == null) {
      filtered = all;
    } else {
      final from = Patient.ymd(range.from);
      final to = Patient.ymd(range.to);
      filtered = all
          .where((m) {
            final key = Patient.ymd(m.date);
            return key.compareTo(from) >= 0 && key.compareTo(to) <= 0;
          })
          .toList();
    }

    final start = (page - 1) * perPage;
    final slice = start >= filtered.length
        ? <Patient>[]
        : filtered.skip(start).take(perPage).toList();

    return (items: slice, total: filtered.length);
  }

  /// Patients still missing identifying details (e.g. quick marksheet
  /// adds), oldest first — the completion queue.
  Future<List<Patient>> fetchNeedingDetails() async {
    await _ensureLoaded();
    final rows = _patients.values.where((p) => p.needsDetails).toList()
      ..sort(
        (a, b) => (a.createdAt ?? a.date).compareTo(b.createdAt ?? b.date),
      );
    return rows;
  }

  Future<Patient?> fetchOne(String id) async {
    await _ensureLoaded();
    return _patients[id];
  }

  Future<Patient> add(Patient patient) async {
    await _ensureLoaded();
    final stored = patient.normalizedForSave();
    final id = localClientId();
    final created = stored.copyWith(id: id);
    await _db.put(
      collectionName,
      Patient.toData(created),
      id: id,
    );
    _patients[id] = created;
    _bump();
    return created;
  }

  Future<Patient> save(Patient patient) async {
    await _ensureLoaded();
    final existing = _patients[patient.id];
    if (existing == null) {
      throw StateError('save() needs a stored patient; use add() for new rows');
    }
    final stored = patient.normalizedForSave().copyWith(id: patient.id);
    await _db.patch(collectionName, patient.id, Patient.toData(stored));
    _patients[patient.id] = stored;
    _bump();
    return stored;
  }

  Future<void> remove(String id) async {
    await _ensureLoaded();
    if (_patients.remove(id) == null) return;
    await _db.drop(collectionName, id);
    _bump();
  }

  SheetTally tally(Iterable<Patient> patients) {
    final out = <DutyShift, Map<CaseType, int>>{
      for (final s in DutyShift.values)
        s: {for (final c in CaseType.values) c: 0},
    };
    for (final m in patients) {
      final row = out[m.shift];
      if (row == null) continue;
      row[m.caseType] = (row[m.caseType] ?? 0) + 1;
    }
    return out;
  }

  int total(SheetTally t) =>
      t.values.expand((row) => row.values).fold(0, (a, b) => a + b);
}

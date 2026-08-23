import 'dart:async';

import 'package:hmis/models/models.dart';
import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/utils/datetime.dart';
import 'package:hmis/utils/router.dart';

final homeController = provider((f) => Home(marksRepository(f)));

/// Home is always "now"; the marksheet's Sheet.dayKey is browsable and
/// deliberately independent of this.
class Home {
  Home(this._repository) {
    _refetch();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      clock.value = DateTime.now();
      final key = Mark.ymd(DateTime.now().shiftDateOf());
      if (key != todayKey.peek()) {
        todayKey.value = key;
        _refetch();
      }
    });
    _revisionWatcher = effect(() {
      _repository.revision();
      _refetch();
    });
  }

  final MarksRepository _repository;

  final clock = signal(DateTime.now(), name: 'home.clock');
  final todayKey = signal(
    Mark.ymd(DateTime.now().shiftDateOf()),
    name: 'home.todayKey',
  );

  final todayList = signal<List<Mark>>(const [], name: 'home.todayList');
  final todayLoading = signal(true, name: 'home.todayLoading');

  late final todayTotal = computed(
    () => todayList().length,
    name: 'home.todayTotal',
  );

  /// One pass instead of 24 .where() scans.
  late final todayByShift = computed(() {
    final out = {for (final s in DutyShift.values) s: 0};
    for (final m in todayList()) out[m.shift] = out[m.shift]! + 1;
    return out;
  }, name: 'home.todayByShift');

  late final todayByType = computed(() {
    final out = {for (final c in CaseType.values) c: 0};
    for (final m in todayList()) out[m.caseType] = out[m.caseType]! + 1;
    return out;
  }, name: 'home.todayByType');

  /// Named patients, newest first. Nulls sort last rather than throwing.
  late final recentNamed = computed(() {
    final list = todayList().where((m) => m.patientName != null).toList()
      ..sort((a, b) {
        final x = a.createdAt, y = b.createdAt;
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        return y.compareTo(x);
      });
    return list.take(10).toList();
  }, name: 'home.recentNamed');

  Future<void> _refetch() async {
    todayLoading.value = true;
    try {
      todayList.value = await _repository.fetchBySheetDate(todayKey.peek());
    } finally {
      todayLoading.value = false;
    }
  }

  late final Timer _ticker;
  late final Dispose _revisionWatcher;

  void dispose() {
    _ticker.cancel();
    _revisionWatcher();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.clock,
    required this.todayKey,
    this.todayList = const [],
    this.todayLoading = true,
  });

  final DateTime clock;
  final String todayKey;
  final List<Mark> todayList;
  final bool todayLoading;

  int get todayTotal => todayList.length;

  Map<DutyShift, int> get todayByShift {
    final out = {for (final s in DutyShift.values) s: 0};
    for (final m in todayList) {
      out[m.shift] = out[m.shift]! + 1;
    }
    return out;
  }

  Map<CaseType, int> get todayByType {
    final out = {for (final c in CaseType.values) c: 0};
    for (final m in todayList) {
      out[m.caseType] = out[m.caseType]! + 1;
    }
    return out;
  }

  List<Mark> get recentNamed {
    final list = todayList.where((m) => m.patientName != null).toList()
      ..sort((a, b) {
        final x = a.createdAt, y = b.createdAt;
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        return y.compareTo(x);
      });
    return list.take(10).toList();
  }

  HomeState copyWith({
    DateTime? clock,
    String? todayKey,
    List<Mark>? todayList,
    bool? todayLoading,
  }) => HomeState(
    clock: clock ?? this.clock,
    todayKey: todayKey ?? this.todayKey,
    todayList: todayList ?? this.todayList,
    todayLoading: todayLoading ?? this.todayLoading,
  );

  @override
  List<Object?> get props => [clock, todayKey, todayList, todayLoading];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository)
    : super(
        HomeState(
          clock: DateTime.now(),
          todayKey: HospitalTime.sheetKeyFor(DateTime.now()),
        ),
      ) {
    _revisionSub = _repository.revisions.listen((_) {
      unawaited(_refetch());
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final MarksRepository _repository;
  late final Timer _ticker;
  StreamSubscription<int>? _revisionSub;

  void initialize() => _refetch();

  Future<void> refresh() => _refetch();

  void _tick() {
    final now = DateTime.now();
    final key = HospitalTime.sheetKeyFor(now);
    final prev = state.clock;
    final sheetRollover = key != state.todayKey;
    final minuteChanged = now.minute != prev.minute ||
        now.hour != prev.hour ||
        now.day != prev.day;

    if (sheetRollover) {
      emit(state.copyWith(clock: now, todayKey: key));
      unawaited(_refetch());
    } else if (minuteChanged) {
      emit(state.copyWith(clock: now));
    }
  }

  Future<void> _refetch() async {
    emit(state.copyWith(todayLoading: true));
    try {
      final list = await _repository.fetchBySheetDate(state.todayKey);
      emit(state.copyWith(todayList: list, todayLoading: false));
    } catch (_) {
      emit(state.copyWith(todayLoading: false));
    }
  }

  @override
  Future<void> close() {
    _ticker.cancel();
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

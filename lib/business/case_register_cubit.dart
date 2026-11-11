import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/models/models.dart';
import 'package:hmis/domain/repositories/patients_repository.dart';

const _pageSize = 50;

class CaseRegisterState extends Equatable {
  const CaseRegisterState({
    this.range,
    this.patients = const [],
    this.loadingMore = false,
    this.exhausted = false,
  });

  final DateRange? range;
  final List<Patient> patients;
  final bool loadingMore;
  final bool exhausted;

  Map<DateTime, List<Patient>> get groupedByDay {
    final grouped = <DateTime, List<Patient>>{};
    for (final patient in patients) {
      grouped.putIfAbsent(patient.date, () => []).add(patient);
    }
    for (final list in grouped.values) {
      list.sort(
        (a, b) => (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date),
      );
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  CaseRegisterState copyWith({
    DateRange? range,
    bool clearRange = false,
    List<Patient>? patients,
    bool? loadingMore,
    bool? exhausted,
  }) => CaseRegisterState(
    range: clearRange ? null : (range ?? this.range),
    patients: patients ?? this.patients,
    loadingMore: loadingMore ?? this.loadingMore,
    exhausted: exhausted ?? this.exhausted,
  );

  @override
  List<Object?> get props => [range, patients, loadingMore, exhausted];
}

class CaseRegisterCubit extends Cubit<CaseRegisterState> {
  CaseRegisterCubit(this._repository) : super(const CaseRegisterState()) {
    _revisionSub = _repository.revisions.listen((_) => _reset());
  }

  final PatientsRepository _repository;
  StreamSubscription<int>? _revisionSub;
  int _page = 1;

  void setRange(DateRange? r) {
    emit(state.copyWith(range: r));
    _reset();
    loadMore();
  }

  void _reset() {
    _page = 1;
    emit(state.copyWith(patients: const [], exhausted: false));
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.exhausted) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final result = await _repository.fetchPage(
        page: _page,
        perPage: _pageSize,
        range: state.range,
      );
      emit(
        state.copyWith(
          patients: [...state.patients, ...result.items],
          exhausted: result.items.length < _pageSize,
        ),
      );
      _page++;
    } finally {
      emit(state.copyWith(loadingMore: false));
    }
  }

  @override
  Future<void> close() {
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

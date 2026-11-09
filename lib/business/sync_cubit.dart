import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/repositories/marks_repository.dart';
import 'package:hmis/services/pocketbase.dart';
import 'package:hmis/domain/repositories/sync_repository.dart';

class SyncState extends Equatable {
  const SyncState({
    this.syncing = false,
    this.pendingOutbox = 0,
    this.lastError,
    this.lastSyncedAt,
  });

  final bool syncing;
  final int pendingOutbox;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncState copyWith({
    bool? syncing,
    int? pendingOutbox,
    String? lastError,
    bool clearError = false,
    DateTime? lastSyncedAt,
  }) => SyncState(
    syncing: syncing ?? this.syncing,
    pendingOutbox: pendingOutbox ?? this.pendingOutbox,
    lastError: clearError ? null : (lastError ?? this.lastError),
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );

  @override
  List<Object?> get props => [syncing, pendingOutbox, lastError, lastSyncedAt];
}

class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._engine, this._service, this._repository)
    : super(const SyncState()) {
    unawaited(_refreshCounts());
    _revisionSub = _repository.revisions.listen((_) {
      unawaited(_refreshCounts());
    });
  }

  final SyncRepository _engine;
  final PocketBaseService _service;
  final MarksRepository _repository;

  Timer? _timer;
  StreamSubscription<int>? _revisionSub;

  void startPeriodicSync() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 45), (_) => syncNow());
  }

  void stopPeriodicSync() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> syncNow() async {
    final session = await _service.readSession();
    if (!session.isOpen || await _engine.readBusy()) {
      await _refreshCounts();
      return;
    }
    emit(state.copyWith(syncing: true, clearError: true));
    try {
      await _engine.syncIfPossible(_service);
      final pending = await _repository.pendingOutboxCount();
      emit(
        state.copyWith(
          syncing: false,
          lastSyncedAt: DateTime.now(),
          pendingOutbox: pending,
        ),
      );
    } catch (e) {
      final pending = await _repository.pendingOutboxCount();
      emit(
        state.copyWith(
          syncing: false,
          lastError: e.toString(),
          pendingOutbox: pending,
        ),
      );
    }
  }

  Future<void> _refreshCounts() async {
    final pending = await _repository.pendingOutboxCount();
    emit(state.copyWith(pendingOutbox: pending));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    unawaited(_revisionSub?.cancel());
    return super.close();
  }
}

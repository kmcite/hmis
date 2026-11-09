import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/business/sync_cubit.dart';
import 'package:hmis/domain/repositories/pocketbase_provisioner.dart';
import 'package:hmis/services/pocketbase.dart';

enum SyncConnectionStatus { disconnected, connecting, connected, error }

class SyncConnectionState extends Equatable {
  const SyncConnectionState({
    this.syncEnabled = false,
    this.status = SyncConnectionStatus.disconnected,
    this.errorMessage,
    this.linkUnstable = false,
    this.hostInput = '192.168.0.111',
  });

  final bool syncEnabled;
  final SyncConnectionStatus status;
  final String? errorMessage;
  final bool linkUnstable;
  final String hostInput;

  bool get isConnected => status == SyncConnectionStatus.connected;
  bool get isConnecting => status == SyncConnectionStatus.connecting;
  bool get canConnect =>
      syncEnabled && hostInput.trim().isNotEmpty && !isConnecting;

  SyncConnectionState copyWith({
    bool? syncEnabled,
    SyncConnectionStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? linkUnstable,
    String? hostInput,
  }) =>
      SyncConnectionState(
        syncEnabled: syncEnabled ?? this.syncEnabled,
        status: status ?? this.status,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
        linkUnstable: linkUnstable ?? this.linkUnstable,
        hostInput: hostInput ?? this.hostInput,
      );

  @override
  List<Object?> get props => [
        syncEnabled,
        status,
        errorMessage,
        linkUnstable,
        hostInput,
      ];
}

/// PocketBase link: prefs, connect/disconnect, provision, health checks.
class SyncConnectionCubit extends Cubit<SyncConnectionState> {
  SyncConnectionCubit(
    this._service,
    this._syncCubit,
  ) : super(const SyncConnectionState()) {
    unawaited(_bootstrap());
  }

  final PocketBaseService _service;
  final SyncCubit _syncCubit;

  final _provisioner = const PocketBaseProvisioner();

  static const hostPresets = {
    'Local (127.0.0.1)': '127.0.0.1',
    'LAN (10.11.84.249)': '10.11.84.249',
  };

  Timer? _heartbeat;

  Future<void> _bootstrap() async {
    final enabled = await _service.isSyncEnabled();
    final host = await _service.getStoredHost() ?? '';
    emit(
      state.copyWith(
        syncEnabled: enabled,
        hostInput: host.isEmpty ? state.hostInput : host,
      ),
    );
    if (enabled && host.isNotEmpty) {
      await connect(host);
    }
  }

  Future<void> setSyncEnabled(bool enabled) async {
    await _service.setSyncEnabled(enabled);
    emit(state.copyWith(syncEnabled: enabled));
    if (!enabled) {
      await disconnect();
    }
  }

  void setHostInput(String value) => emit(state.copyWith(hostInput: value));

  Future<void> provisionAndConnect({
    required String adminEmail,
    required String adminPassword,
  }) async {
    final host = state.hostInput.trim();
    if (host.isEmpty) return;

    emit(
      state.copyWith(
        status: SyncConnectionStatus.connecting,
        clearErrorMessage: true,
        linkUnstable: false,
      ),
    );

    try {
      final session = await _service.open(host);
      await _provisioner.ensureMarksCollection(
        session.requireClient,
        adminEmail: adminEmail,
        adminPassword: adminPassword,
      );
      await session.requireClient.health.check().timeout(
            const Duration(seconds: 5),
          );
      await _service.setStoredHost(host);
      await _service.setSyncEnabled(true);
      emit(
        state.copyWith(
          syncEnabled: true,
          status: SyncConnectionStatus.connected,
        ),
      );
      _syncCubit.startPeriodicSync();
      await _syncCubit.syncNow();
      _startHeartbeat();
    } catch (e) {
      await _service.close();
      emit(
        state.copyWith(
          status: SyncConnectionStatus.error,
          errorMessage: 'Setup failed: $e',
        ),
      );
    }
  }

  Future<void> connect([String? target]) async {
    if (!state.syncEnabled) return;
    final t = (target ?? state.hostInput).trim();
    if (t.isEmpty || state.isConnecting) return;

    emit(
      state.copyWith(
        status: SyncConnectionStatus.connecting,
        clearErrorMessage: true,
        linkUnstable: false,
      ),
    );

    try {
      final session = await _service.open(t);
      await session.requireClient.health.check().timeout(
            const Duration(seconds: 5),
          );
      await _service.setStoredHost(t);
      emit(state.copyWith(status: SyncConnectionStatus.connected));
      _syncCubit.startPeriodicSync();
      await _syncCubit.syncNow();
      _startHeartbeat();
    } catch (_) {
      await _service.close();
      emit(
        state.copyWith(
          status: SyncConnectionStatus.error,
          errorMessage: 'Connection failed: $t',
        ),
      );
    }
  }

  Future<void> disconnect() async {
    _heartbeat?.cancel();
    _syncCubit.stopPeriodicSync();
    await _service.close();
    emit(
      state.copyWith(
        status: SyncConnectionStatus.disconnected,
        linkUnstable: false,
      ),
    );
  }

  static const _maxFailures = 2;

  void _startHeartbeat() {
    _heartbeat?.cancel();
    var failures = 0;
    var busy = false;
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) async {
      final session = await _service.readSession();
      if (busy || !session.isOpen) return;
      busy = true;
      try {
        await session.requireClient.health.check().timeout(
              const Duration(seconds: 4),
            );
        failures = 0;
        if (state.linkUnstable) emit(state.copyWith(linkUnstable: false));
        await _syncCubit.syncNow();
      } catch (_) {
        failures++;
        if (failures >= _maxFailures) {
          emit(
            state.copyWith(
              linkUnstable: false,
              status: SyncConnectionStatus.error,
              errorMessage: 'Server unreachable',
            ),
          );
          _heartbeat?.cancel();
        } else {
          emit(state.copyWith(linkUnstable: true));
        }
      } finally {
        busy = false;
      }
    });
  }

  @override
  Future<void> close() {
    _heartbeat?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:hmis/repositories/marks_repository.dart';
import 'package:hmis/services/pocketbase.dart';
import 'package:hmis/utils/router.dart';

final pocketbaseGateProvider = provider(
  (f) => PocketbaseGate(pocketBaseServiceProvider(f), marksRepository(f)),
);

enum PbStatus { disconnected, connecting, connected, error }

class PocketbaseGate {
  PocketbaseGate(this._service, this._repository);

  final PocketBaseService _service;
  final MarksRepository _repository;

  static const _hostKey = 'pb_host';
  static const pbPresets = {
    'Local (127.0.0.1)': '127.0.0.1',
    'LAN (10.11.84.249)': '10.11.84.249',
  };

  final pbStatus = signal(PbStatus.disconnected, name: 'PocketbaseGate.pbStatus');
  final pbError = signal<String?>(null, name: 'PocketbaseGate.pbError');
  final pbDegraded = signal(false, name: 'PocketbaseGate.pbDegraded');

  /// Text field contents — separate from the committed host, which only
  /// changes on a successful handshake so a typo can't tear down a live
  /// client.
  final pbHostInput = signal('192.168.0.111', name: 'PocketbaseGate.pbHostInput');

  late final pbIsLive = computed(
    () => pbStatus() == PbStatus.connected,
    name: 'PocketbaseGate.pbIsLive',
  );
  late final pbIsConnecting = computed(
    () => pbStatus() == PbStatus.connecting,
    name: 'PocketbaseGate.pbIsConnecting',
  );
  late final pbCanConnect = computed(
    () => pbHostInput().trim().isNotEmpty && !pbIsConnecting(),
    name: 'PocketbaseGate.pbCanConnect',
  );

  /// Restores the last good host. Call once prefs resolve.
  Future<void> restoreHost() async {
    final saved = await _service.preferences.getString(_hostKey);
    if (saved == null || saved.isEmpty) return;
    pbHostInput.value = saved;
    await connectPb(saved);
  }

  Future<void> connectPb([String? target]) async {
    final t = (target ?? pbHostInput.peek()).trim();
    if (t.isEmpty || pbIsConnecting.peek()) return;

    pbStatus.value = PbStatus.connecting;
    pbError.value = null;
    pbDegraded.value = false;

    try {
      await _service.open(t);
      await _service.pocketbase.health.check().timeout(
        const Duration(seconds: 5),
      );
      await _service.preferences.setString(_hostKey, t);
      await _repository.startWatching();
      pbStatus.value = PbStatus.connected;
      _startHeartbeat();
    } catch (_) {
      pbStatus.value = PbStatus.error;
      pbError.value = 'CONNECTION FAILED: $t';
    }
  }

  void disconnectPb() {
    _heartbeat?.cancel();
    pbStatus.value = PbStatus.disconnected;
    pbDegraded.value = false;
  }

  /// Heartbeat. Restarted on every successful connect; cancelled on
  /// disconnect so it never overlaps a new client.
  static const _maxFailures = 2;
  Timer? _heartbeat;

  void _startHeartbeat() {
    _heartbeat?.cancel();
    var failures = 0;
    var busy = false; // a slow check must not overlap the next tick
    _heartbeat = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (busy || !_service.isOpen) return;
      busy = true;
      try {
        await _service.pocketbase.health.check().timeout(
          const Duration(seconds: 4),
        );
        failures = 0;
        if (pbDegraded.peek()) pbDegraded.value = false;
      } catch (_) {
        failures++;
        if (failures >= _maxFailures) {
          pbDegraded.value = false;
          pbStatus.value = PbStatus.error;
          pbError.value = 'SERVER LOST — connection dropped';
          _heartbeat?.cancel();
        } else {
          pbDegraded.value = true;
        }
      } finally {
        busy = false;
      }
    });
  }
}

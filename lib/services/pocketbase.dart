import 'dart:async';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Active or closed PocketBase client — read via [readSession] / [session].
class PocketBaseSession {
  const PocketBaseSession.closed() : client = null;

  const PocketBaseSession._(this.client);

  final PocketBase? client;

  bool get isOpen => client != null;

  PocketBase get requireClient {
    final c = client;
    if (c == null) {
      throw StateError('PocketBase is not connected');
    }
    return c;
  }
}

/// PocketBase client for optional sync — no end-user auth.
///
/// Connection changes are published on [session]; prefs and connect/disconnect
/// are async only (no [ChangeNotifier]).
class PocketBaseService {
  PocketBaseService() : _prefs = SharedPreferencesAsync();

  static const syncEnabledKey = 'sync_enabled';
  static const hostKey = 'pb_host';

  final SharedPreferencesAsync _prefs;
  final _sessionController = StreamController<PocketBaseSession>.broadcast();

  PocketBaseSession _session = const PocketBaseSession.closed();

  /// Fires after each successful [open] or [close].
  Stream<PocketBaseSession> get session => _sessionController.stream;

  Future<PocketBaseSession> readSession() async => _session;

  Future<bool> isSyncEnabled() async =>
      await _prefs.getBool(syncEnabledKey) ?? false;

  Future<void> setSyncEnabled(bool value) async {
    await _prefs.setBool(syncEnabledKey, value);
  }

  Future<String?> getStoredHost() async => _prefs.getString(hostKey);

  Future<void> setStoredHost(String host) async {
    await _prefs.setString(hostKey, host);
  }

  Future<PocketBaseSession> open(String host) async {
    final target = Platform.isAndroid ? '127.0.0.1' : host;
    final client = PocketBase('http://$target:8090');
    _session = PocketBaseSession._(client);
    _sessionController.add(_session);
    return _session;
  }

  Future<PocketBaseSession> close() async {
    _session = const PocketBaseSession.closed();
    _sessionController.add(_session);
    return _session;
  }

  void dispose() {
    unawaited(close());
    _sessionController.close();
  }
}

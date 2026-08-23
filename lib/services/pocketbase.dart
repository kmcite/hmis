import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hmis/utils/router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pocketBaseServiceProvider = provider((f) => PocketBaseService());

class PocketBaseService extends ChangeNotifier {
  static const key = "auth_key";
  SharedPreferencesAsync preferences = SharedPreferencesAsync();
  PocketBase? _pocketBase;

  PocketBase get pocketbase => _pocketBase!;
  bool get isOpen => _pocketBase != null;

  /// Termux binds >1024 without root, so the server is on 8090, and Android
  /// reaches it via loopback (0.0.0.0 is a bind address, not a connect target).
  Future<void> open(String host) async {
    final target = Platform.isAndroid ? '127.0.0.1' : host;
    _pocketBase = PocketBase(
      'http://$target:8090',
      authStore: AsyncAuthStore(
        save: (token) => preferences.setString(key, token),
        initial: await preferences.getString(key),
      ),
    );
    notifyListeners();
  }

  Future<void> close() async {
    _pocketBase?.close();
    _pocketBase = null;
  }
}

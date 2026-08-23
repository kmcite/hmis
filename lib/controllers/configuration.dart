import 'package:flutter/material.dart' show ThemeMode;
import 'package:hmis/services/pocketbase.dart';
import 'package:hmis/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final configuration = provider(
  (f) => Configuration(pocketBaseServiceProvider(f).preferences),
);

class Configuration {
  Configuration(this._prefs) {
    _init();
  }

  static const _key = 'dark_key';
  final SharedPreferencesAsync _prefs;

  final dark = signal(false, name: 'configuration.dark');

  late final themeMode = computed(
    () => dark() ? ThemeMode.dark : ThemeMode.light,
    name: 'configuration.themeMode',
  );

  void toggleDark() async {
    dark.value = !dark.peek();
    await _prefs.setBool(_key, dark.peek());
  }

  void _init() async {
    dark.value = await _prefs.getBool(_key) ?? false;
  }
}

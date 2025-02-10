import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  Future<void> save(String key, String value) async {
    (await prefs).setString(key, value);
  }

  Future<String?> load(String key) async {
    return (await prefs).getString(key);
  }
}

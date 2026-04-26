import 'package:shared_preferences/shared_preferences.dart';

extension ReadWrite on SharedPreferences {
  void write(String key, String value) async {
    await setString(key, value);
  }

  String? read(String key) => getString(key);
}

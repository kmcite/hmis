import 'package:hmis/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final String userName;
  final ThemeMode themeMode;
  const Settings({
    this.userName = '',
    this.themeMode = ThemeMode.system,
  });

  Settings copyWith({
    String? userName,
    ThemeMode? themeMode,
  }) {
    return Settings(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  String toJson() {
    final Map<String, dynamic> data = {
      'userName': userName,
      'themeMode': themeMode.index,
    };
    return jsonEncode(data);
  }

  factory Settings.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return Settings(
      userName: data['userName'] ?? '',
      themeMode: ThemeMode.values[data['themeMode'] ?? 0],
    );
  }
}

class SettingsRepository {
  SharedPreferences preferences;
  SettingsRepository(this.preferences);

  static const key = 'settings';
  Settings get settings =>
      Settings.fromJson(preferences.getString(key) ?? '{}');

  void setSettings(Settings settings) {
    preferences.setString(key, settings.toJson());
  }

  /// THEME MODE
  ThemeMode get themeMode => settings.themeMode;

  void setThemeMode(ThemeMode? themeMode) =>
      setSettings(settings.copyWith(themeMode: themeMode));

  /// USER NAME
  String get userName => settings.userName;
  void setUserName(String? value) =>
      setSettings(settings.copyWith(userName: value));
}

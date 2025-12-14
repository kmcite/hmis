import 'package:hmis/main.dart';

class SettingsBloc with ChangeNotifier {
  final BuildContext context;
  SettingsBloc(this.context);
  SettingsRepository get _settingsRepository => throw ();

  ThemeMode get themeMode => _settingsRepository.themeMode;
  // String get hospitalName => _settingsRepository.hospitalName;
  String get userName => _settingsRepository.userName;

  void setThemeMode(ThemeMode? themeMode) {
    _settingsRepository.setThemeMode(themeMode);
    notifyListeners();
  }

  void setUserName(String? themeMode) {
    _settingsRepository.setUserName(themeMode);
    notifyListeners();
  }

  // void setHospitalName(String? themeMode) {
  //   _settingsRepository.setHospitalName(themeMode);
  //   notifyListeners();
  // }

  void toggleThemeMode() {
    if (themeMode == ThemeMode.system) {
      setThemeMode(
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? ThemeMode.light
            : ThemeMode.dark,
      );
    } else {
      setThemeMode(
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );
    }
    notifyListeners();
  }
}

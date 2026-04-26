import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final DateTime currentlySelectedDate;
  final bool dark;

  const SettingsState({
    required this.currentlySelectedDate,
    this.dark = false,
  });

  SettingsState copyWith({
    DateTime? currentlySelectedDate,
    bool? dark,
  }) {
    return SettingsState(
      currentlySelectedDate:
          currentlySelectedDate ?? this.currentlySelectedDate,
      dark: dark ?? this.dark,
    );
  }

  String get currentDateFormatted =>
      '${currentlySelectedDate.day}/${currentlySelectedDate.month}/${currentlySelectedDate.year}';
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;
  SettingsCubit(this.prefs)
    : super(
        SettingsState(
          currentlySelectedDate: DateTime.now(),
          dark: prefs.getBool(DARK) ?? true,
        ),
      );

  void onCurrentlySelectedDateChanged(DateTime date) {
    emit(state.copyWith(currentlySelectedDate: date));
  }

  void onDarkChanged(bool dark) {
    emit(state.copyWith(dark: dark));
    prefs.setBool(DARK, dark);
  }

  void onDarkToggled() {
    onDarkChanged(!state.dark);
  }

  static const DARK = 'dark';
}

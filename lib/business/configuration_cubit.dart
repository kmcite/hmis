import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationState extends Equatable {
  const ConfigurationState({this.dark = false});

  final bool dark;

  ThemeMode get themeMode => dark ? ThemeMode.dark : ThemeMode.light;

  ConfigurationState copyWith({bool? dark}) =>
      ConfigurationState(dark: dark ?? this.dark);

  @override
  List<Object?> get props => [dark];
}

class ConfigurationCubit extends Cubit<ConfigurationState> {
  ConfigurationCubit(this._prefs) : super(const ConfigurationState());

  static const _key = 'dark_key';
  final SharedPreferencesAsync _prefs;

  Future<void> initialize() async {
    emit(
      ConfigurationState(dark: await _prefs.getBool(_key) ?? false),
    );
  }

  Future<void> toggleDark() async {
    await setDark(!state.dark);
  }

  Future<void> setDark(bool value) async {
    if (value == state.dark) return;
    emit(state.copyWith(dark: value));
    await _prefs.setBool(_key, value);
  }
}

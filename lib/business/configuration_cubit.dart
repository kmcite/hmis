import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmis/domain/repositories/app_settings_store.dart';

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
  ConfigurationCubit(this._settings) : super(const ConfigurationState());

  final AppSettingsStore _settings;

  Future<void> initialize() async {
    emit(ConfigurationState(dark: await _settings.readDark()));
  }

  Future<void> toggleDark() async {
    await setDark(!state.dark);
  }

  Future<void> setDark(bool value) async {
    if (value == state.dark) return;
    emit(state.copyWith(dark: value));
    await _settings.writeDark(value);
  }
}

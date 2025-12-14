import 'package:hmis/main.dart';

mixin Single<T> {
  String get key;
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T value);

  T get value => fromJson(jsonDecode(preferences.getString(key) ?? '{}'));

  void update(T value) {
    preferences.setString(key, jsonEncode(toJson(value)));
  }
}

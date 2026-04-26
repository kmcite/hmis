import 'package:hmis/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:objectbox/objectbox.dart';

Future<void> restoreAppication(SharedPreferences prefs, Store store) async {
  await prefs.clear();
  store.box<ErMark>().removeAll();
  // store.box<Investigation>().removeAll();
}

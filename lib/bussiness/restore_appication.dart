import 'package:hmis/bussiness/business.dart';
import 'package:hmis/domain/er_mark.dart';
import 'package:hmis/domain/services.dart';
import 'package:hmis/main.dart';
import 'package:redux/redux.dart';

class RestoreAppication {}

class RestoreApplicationMW extends MiddlewareClass<Business> {
  @override
  void call(store, action, next) async {
    next(action);
    if (action is RestoreAppication) {
      await preferences.clear();
      await objects.box<ErMark>().removeAll();
      await objects.box<Investigation>().removeAll();
    }
  }
}

import 'package:redux/redux.dart';

class LoggingMW extends MiddlewareClass {
  @override
  call(store, action, next) {
    next(action);
    print(action.runtimeType);
  }
}

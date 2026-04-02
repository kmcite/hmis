import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:redux/redux.dart';

class NativeSplashRemovalMW extends MiddlewareClass {
  bool isSplashOnScreen = true;
  @override
  call(store, action, next) {
    next(action);
    if (action is FlutterNativeSplashRemoved && isSplashOnScreen) {
      FlutterNativeSplash.remove();
      isSplashOnScreen = false;
    }
  }
}

class FlutterNativeSplashRemoved {}

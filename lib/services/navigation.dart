import 'package:flutter/cupertino.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<T?> navigateTo<T extends Object?>(Widget page) async {
  return await navigatorKey.currentState?.push(
    CupertinoPageRoute(builder: (context) => page),
  );
}

void navigateBack<T extends Object?>([T? result]) {
  return navigatorKey.currentState?.pop();
}

Future<T?> navigateToDialog<T>(Widget dialog) async {
  final context = navigatorKey.currentContext;
  if (context != null) {
    return await showCupertinoDialog(
      context: context,
      builder: (context) => dialog,
    );
  }
  return null;
}

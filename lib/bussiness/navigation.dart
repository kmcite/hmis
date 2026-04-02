import 'package:hmis/bussiness/business.dart';
import 'package:hmis/main.dart';
import 'package:redux/redux.dart';

class Navigation extends MiddlewareClass<Business> {
  @override
  call(store, action, next) {
    next(action);
    switch (action) {
      case NavigateTo():
        // Handle navigation
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => action.to),
        );
        break;
      case NavigateBack():
        // Handle back navigation
        navigatorKey.currentState?.pop();
        break;
      case ShowDialog():
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => action.to,
        );
        break;
      default:
        break;
    }
  }
}

sealed class NavigationAction {
  const NavigationAction();
}

class NavigateTo<W extends Widget> extends NavigationAction {
  final W to;
  const NavigateTo(this.to);
}

class NavigateBack extends NavigationAction {
  const NavigateBack();
}

class ShowDialog<D extends Widget> extends NavigationAction {
  final D to;
  const ShowDialog(this.to);
}

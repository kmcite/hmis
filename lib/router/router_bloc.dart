import 'package:hmis/router/router_repository.dart';
import 'package:hmis/main.dart';

class RouterBloc with ChangeNotifier {
  final BuildContext context;
  RouterBloc(this.context);
  RouterRepository get _routerRepository => context.of();

  GoRouter get router => _routerRepository.router;

  void toRouteByName(String name) {
    _routerRepository.toRouteByName(name);
  }

  void toRouteByPath(String path) {
    _routerRepository.toRouteByPath(path);
    notifyListeners();
  }

  Future<T?> dialog<T>(Widget dialog) =>
      showDialog(context: context, builder: (context) => dialog);
}

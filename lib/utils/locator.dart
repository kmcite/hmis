import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/material.dart' as material;
import 'package:hmis/domain/domain.dart';
import 'package:hmis/utils/router.dart';

final _instances = <Type, ChangeNotifier>{};

void put<T extends ChangeNotifier>(T instance) {
  _instances[T] = instance;
}

T find<T extends ChangeNotifier>() {
  final instance = _instances[T];
  if (instance == null) {
    throw Exception('No instance of type $T found in app.');
  }
  return instance as T;
}

extension DependencyInjection on material.StatelessWidget {
  Router get router => find<Router>();
  ErRegisterRepository get erRegisterRepository => find<ErRegisterRepository>();
}

abstract class State<T extends material.StatefulWidget>
    extends material.State<T>
    with _WatchMixin<T> {
  late Router router = watch();
  late ErRegisterRepository erRegisterRepository = watch();
}

mixin _WatchMixin<T extends material.StatefulWidget> on material.State<T> {
  late void Function() unsubscribe = () {};
  late final void Function() listener = () {
    if (mounted) setState(() {});
  };
  U watch<U extends ChangeNotifier>() {
    final instance = find<U>();
    instance.addListener(listener);
    unsubscribe = () => instance.removeListener(listener);
    return instance;
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}

import 'package:hmis/domain/services.dart';

/// lets re-implement this crud based system off to redux based
abstract class ObjectBoxActions {
  const ObjectBoxActions();
  void call();
}

class Put<T> extends ObjectBoxActions {
  final T object;
  const Put(this.object);
  @override
  void call() {
    objects.box<T>().put(object);
  }
}

class Remove<T> extends ObjectBoxActions {
  final T any;
  const Remove(this.any);
  @override
  void call() {
    objects.box<T>().remove((any as dynamic).id);
  }
}

class RemoveAll<T> extends ObjectBoxActions {
  const RemoveAll();
  @override
  void call() {
    objects.box<T>().removeAll();
  }
}

import 'package:objectbox/objectbox.dart';

extension StoreApi on Store {
  void put<T>(T object) {
    box<T>().put(object);
  }

  void remove<T>(T any) {
    box<T>().remove((any as dynamic).id);
  }

  void removeAll<T>() {
    box<T>().removeAll();
  }
}

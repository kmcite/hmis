import 'package:hmis/main.dart';

mixin CRUD<T> {
  final box = store.box<T>();
  late final getAll = box.getAll;
  late final get = box.get;
  late final put = box.put;
  late final removeAll = box.removeAll;
  late final remove = box.remove;
}

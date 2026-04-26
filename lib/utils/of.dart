import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext, WatchContext;

extension OfContext on BuildContext {
  T of<T>() {
    try {
      return watch<T>();
    } catch (_) {
      return read<T>();
    }
  }
}

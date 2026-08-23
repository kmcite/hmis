import 'dart:async';

import 'package:hmis/utils/router.dart';

final currentDateController = provider((f) => CurrentDate());

class CurrentDate {
  CurrentDate() {
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => date.value = DateTime.now(),
    );
  }

  final date = signal(DateTime.now(), name: 'current_date.date');
  late final Timer _ticker;

  void dispose() => _ticker.cancel();
}

import 'package:hmis/ui/screens/new_chit_screen.dart';
import 'package:hmis/ui/screens/case_register_screen.dart';
import 'package:hmis/ui/screens/home_screen.dart';
import 'package:hmis/ui/screens/marksheet.dart';

import 'router.dart';

export 'package:signals/signals.dart'
    show
        SignalRouter,
        Bloc,
        Cubit,
        RouterScope,
        provider,
        ProviderScope,
        SignalConsumer,
        Watch,
        WatchExtension,
        signal,
        computed,
        effect,
        Dispose,
        listSignal,
        ListSignal,
        Signal,
        ReadonlySignal;

sealed class const AppRoute();
class const HomeRoute() extends AppRoute;
class const NewChitRoute() extends AppRoute;
class const MarksheetRoute() extends AppRoute;
class const CaseRegisterRoute() extends AppRoute;

final router = SignalRouter<AppRoute>(
  initialRoute: HomeRoute(),
  builder: (route) {
    return switch (route) {
      HomeRoute() => HomeScreen(),
      NewChitRoute() => NewChitScreen(),
      MarksheetRoute() => MarksheetScreen(),
      CaseRegisterRoute() => CaseRegisterScreen(),
    };
  },
);

import 'package:flutter/material.dart';
import 'package:hmis/controllers/configuration.dart';
import 'package:hmis/ui/pocketbase_gate/pocketbase.dart';
import 'package:hmis/utils/router.dart';
import 'package:signals/signals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    RouterScope(
      router: router,
      child: const ProviderScope(
        child: PocketBaseGate(child: Application()),
      ),
    ),
  );
}

class Application extends SignalConsumer {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: context.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Maple Mono'),
      darkTheme: ThemeData(
        fontFamily: 'Maple Mono',
        brightness: Brightness.dark,
      ),
      themeMode: configuration(context).themeMode(),
    );
  }
}
